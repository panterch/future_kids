# frozen_string_literal: true

# Generates a German-language summary of a kid using an OpenAI-compatible
# chat completions API, configured per site (Site#ai_api_base_url,
# #ai_api_token, #ai_model) so that each deployment can use its own AI
# provider and account. ai_api_base_url is the provider's OpenAI-compatible
# base URL (e.g. ".../openai/v1"), not the full endpoint - the standard
# "/chat/completions" suffix is appended here.
# The prompt is the kid's markdown profile (kids/show.md.erb - the same
# template the admin-only "/kids/:id.md" view renders), which includes the
# kid's name, support areas, mentor/teacher assignment history, and the full
# chronological record (journals, Gespräche, assessments).
class JournalSummarizer
  class Error < StandardError; end

  # used unless a site overrides it via Site#ai_summary_prompt - the markdown
  # profile itself is always appended by build_prompt and is not part of this
  # override, so a custom prompt cannot drop the underlying data
  DEFAULT_PROMPT = <<~PROMPT
    Du unterstützt ein Mentoring-Programm, das Primarschulkinder ausserhalb der
    Schule fördert. Im Folgenden erhältst du das Markdown-Profil eines Kindes:
    allgemeine Angaben, vereinbarte Förderbereiche sowie eine chronologische
    Übersicht über Lernjournal-Einträge, Gesprächsdokumentationen,
    Auswertungen und Änderungen bei Mentor:innen/Lehrpersonen. Fasse den
    Verlauf zusammen. Gehe dabei auf wiederkehrende Themen und den
    Lernfortschritt ein und erwähne, falls auffällig, gehäuft ausgefallene
    Termine. Antworte auf Hochdeutsch mit Schweizer Rechtschreibung,
    in maximal 200 Wörtern, als Fliesstext ohne Aufzählungen.
  PROMPT

  def initialize(kid)
    @kid = kid
    @site = Site.load
  end

  def call
    raise Error, 'Es sind keine Lernjournal-Einträge vorhanden.' if @kid.journals.empty?

    fetch_summary(build_prompt)
  end

  private

  def build_prompt
    markdown = ApplicationController.renderer.render(template: 'kids/show', formats: [:md], assigns: { kid: @kid })
    "#{@site.ai_summary_prompt.presence || DEFAULT_PROMPT}\n\n#{markdown}"
  end

  def fetch_summary(prompt)
    content = JSON.parse(request(prompt).body).dig('choices', 0, 'message', 'content')
    raise Error, 'Die Antwort der KI enthielt keine Zusammenfassung.' if content.blank?

    content.strip
  end

  def request(prompt)
    if @site.ai_api_base_url.blank?
      raise Error, 'Die KI-Anbieter-URL ist in den Seiteneinstellungen nicht konfiguriert.'
    end
    raise Error, 'Der KI-API-Token ist in den Seiteneinstellungen nicht konfiguriert.' if @site.ai_api_token.blank?
    raise Error, 'Das KI-Modell ist in den Seiteneinstellungen nicht konfiguriert.' if @site.ai_model.blank?

    body = {
      model: @site.ai_model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.4
    }.to_json
    headers = { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{@site.ai_api_token}" }

    url = "#{@site.ai_api_base_url.chomp('/')}/chat/completions"
    response = Net::HTTP.post(URI(url), body, headers)
    raise Error, "Die Anfrage an die KI ist fehlgeschlagen (#{response.code})." unless response.is_a?(Net::HTTPSuccess)

    response
  rescue Timeout::Error, SocketError, OpenSSL::SSL::SSLError => e
    raise Error, "Verbindung zur KI ist fehlgeschlagen: #{e.message}"
  end
end
