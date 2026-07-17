# frozen_string_literal: true

# Generates a German-language summary of a kid's journal entries using an
# OpenAI-compatible chat completions API, configured per site (Site#ai_api_url,
# #ai_api_token, #ai_model) so that each deployment can use its own AI provider
# and account. The kid's name is intentionally left out of the prompt so that
# no personally identifying data beyond the free-text journal content itself
# is sent to the third-party API.
class JournalSummarizer
  class Error < StandardError; end

  def initialize(kid)
    @kid = kid
    @site = Site.load
  end

  def call
    journals = @kid.journals.where(cancelled: false).order(:held_at)
    raise Error, 'Es sind keine Lernjournal-Einträge vorhanden.' if journals.empty?

    fetch_summary(build_prompt(journals))
  end

  private

  def build_prompt(journals)
    entries = journals.map do |journal|
      [
        "Datum: #{I18n.l(journal.held_at)}",
        "Thema: #{journal.subject}",
        "Ziel: #{journal.goal}",
        "Methode: #{journal.method}",
        "Ergebnis: #{journal.outcome}",
        "Notiz: #{journal.note}"
      ].join("\n")
    end.join("\n---\n")

    <<~PROMPT
      Du unterstützt ein Mentoring-Programm, das Primarschulkinder ausserhalb der
      Schule fördert. Fasse die folgenden Lernjournal-Einträge eines Kindes
      zusammen. Gehe dabei auf wiederkehrende Themen und den Lernfortschritt ein.
      Antworte auf Deutsch, in maximal 200 Wörtern, als Fliesstext ohne
      Aufzählungen.

      #{entries}
    PROMPT
  end

  def fetch_summary(prompt)
    content = JSON.parse(request(prompt).body).dig('choices', 0, 'message', 'content')
    raise Error, 'Die Antwort der KI enthielt keine Zusammenfassung.' if content.blank?

    content.strip
  end

  def request(prompt)
    raise Error, 'Die KI-Anbieter-URL ist in den Seiteneinstellungen nicht konfiguriert.' if @site.ai_api_url.blank?
    raise Error, 'Der KI-API-Token ist in den Seiteneinstellungen nicht konfiguriert.' if @site.ai_api_token.blank?
    raise Error, 'Das KI-Modell ist in den Seiteneinstellungen nicht konfiguriert.' if @site.ai_model.blank?

    body = {
      model: @site.ai_model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.4
    }.to_json
    headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{@site.ai_api_token}" }

    response = Net::HTTP.post(URI(@site.ai_api_url), body, headers)
    raise Error, "Die Anfrage an die KI ist fehlgeschlagen (#{response.code})." unless response.is_a?(Net::HTTPSuccess)

    response
  rescue Timeout::Error, SocketError, OpenSSL::SSL::SSLError => e
    raise Error, "Verbindung zur KI ist fehlgeschlagen: #{e.message}"
  end
end
