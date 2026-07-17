# frozen_string_literal: true

require 'spec_helper'

describe JournalSummarizer do
  let(:kid) { create(:kid) }

  before do
    Site.load.update!(
      ai_api_url: 'https://api.example.com/v1/chat/completions',
      ai_api_token: 'test-token',
      ai_model: 'llama3'
    )
  end

  def stub_ai_response(code: '200', body: nil)
    response = instance_double(Net::HTTPSuccess, code: code, body: body, is_a?: (code == '200'))
    allow(Net::HTTP).to receive(:post).and_return(response)
    response
  end

  context 'without journal entries' do
    it 'raises an error' do
      expect { described_class.new(kid).call }.to raise_error(described_class::Error, /keine Lernjournal/)
    end
  end

  context 'with journal entries' do
    before { create(:journal, kid: kid) }

    it 'raises an error when the API url is missing' do
      Site.load.update!(ai_api_url: nil)
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

    it 'posts to the configured site endpoint with the stored token' do
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(Net::HTTP).to have_received(:post) do |uri, _body, headers|
        expect(uri.to_s).to eq('https://api.example.com/v1/chat/completions')
        expect(headers['Authorization']).to eq('Bearer test-token')
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

    it 'excludes cancelled journals from the prompt' do
      create(:cancelled_journal, kid: kid, subject: 'Cancelled subject')
      stub_ai_response(body: { choices: [{ message: { content: 'ok' } }] }.to_json)
      described_class.new(kid).call
      expect(Net::HTTP).to have_received(:post) do |_uri, body, _headers|
        prompt = JSON.parse(body)['messages'].first['content']
        expect(prompt).not_to include('Cancelled subject')
      end
    end
  end
end
