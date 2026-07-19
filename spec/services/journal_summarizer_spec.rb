# frozen_string_literal: true

require 'spec_helper'

describe JournalSummarizer do
  let(:kid) { create(:kid) }

  before do
    Site.load.update!(
      ai_api_base_url: 'https://api.example.com/v1',
      ai_api_token: 'test-token',
      ai_model: 'llama3'
    )
  end

  def stub_ai_response(code: '200', body: nil)
    response = instance_double(Net::HTTPSuccess, code: code, body: body, is_a?: (code == '200'))
    @http_double = instance_double(Net::HTTP, post: response)
    allow(Net::HTTP).to receive(:start).and_yield(@http_double)
    response
  end

  def posted_http
    @http_double
  end

  context 'without journal entries' do
    it 'raises an error' do
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /keine Lernjournal/)
    end
  end

  context 'with journal entries' do
    before { create(:journal, kid: kid) }

    it 'raises an error when the API url is missing' do
      Site.load.update!(ai_api_base_url: nil)
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /Anbieter-URL/)
    end

    it 'raises an error when the API token is missing' do
      Site.load.update!(ai_api_token: nil)
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /API-Token/)
    end

    it 'raises an error when the model is missing' do
      Site.load.update!(ai_model: nil)
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /Modell/)
    end

    it 'returns the summary text from a successful response' do
      stub_ai_response(body: { choices: [{ message: { content: ' Zusammenfassung. ' } }] }.to_json)
      expect(described_class.new(kid).call).to eq('Zusammenfassung.')
    end

    it 'posts to the base url with the standard chat/completions suffix and the stored token' do
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(posted_http).to have_received(:post) do |uri, _body, headers|
        expect(uri.to_s).to eq('https://api.example.com/v1/chat/completions')
        expect(headers['Authorization']).to eq('Bearer test-token')
      end
    end

    it 'strips a trailing slash from the configured base url before appending the suffix' do
      Site.load.update!(ai_api_base_url: 'https://api.example.com/v1/')
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(posted_http).to have_received(:post) do |uri, _body, _headers|
        expect(uri.to_s).to eq('https://api.example.com/v1/chat/completions')
      end
    end

    it 'raises an error when the request fails' do
      stub_ai_response(code: '500', body: '')
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /fehlgeschlagen/)
    end

    it 'raises an error when the response has no content' do
      stub_ai_response(body: { choices: [] }.to_json)
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /keine Zusammenfassung/)
    end

    it 'includes cancelled journals in the prompt, marked as cancelled' do
      create(:cancelled_journal, kid: kid, held_at: Date.new(2024, 5, 1))
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(posted_http).to have_received(:post) do |_uri, body, _headers|
        prompt = JSON.parse(body)['messages'].first['content']
        expect(prompt).to include('Lernjournal vom 01.05.2024 (Ausgefallen)')
      end
    end

    it 'uses the default instruction when the site has no custom prompt' do
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(posted_http).to have_received(:post) do |_uri, body, _headers|
        prompt = JSON.parse(body)['messages'].first['content']
        expect(prompt).to include(described_class::DEFAULT_PROMPT.strip)
      end
    end

    it 'uses the site-configured instruction instead of the default when present' do
      Site.load.update!(ai_summary_prompt: 'Fasse alles in einem Satz auf Englisch zusammen.')
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(posted_http).to have_received(:post) do |_uri, body, _headers|
        prompt = JSON.parse(body)['messages'].first['content']
        expect(prompt).to include('Fasse alles in einem Satz auf Englisch zusammen.')
        expect(prompt).not_to include(described_class::DEFAULT_PROMPT.strip)
      end
    end

    it 'still appends the journal entries when a custom prompt is configured' do
      create(:journal, kid: kid, subject: 'Bruchrechnen')
      Site.load.update!(ai_summary_prompt: 'Fasse alles in einem Satz auf Englisch zusammen.')
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(posted_http).to have_received(:post) do |_uri, body, _headers|
        prompt = JSON.parse(body)['messages'].first['content']
        expect(prompt).to include('Bruchrechnen')
      end
    end
  end
end
