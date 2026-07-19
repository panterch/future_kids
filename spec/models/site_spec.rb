# frozen_string_literal: true

require 'spec_helper'

describe Site do
  before do
    @site = described_class.load
  end

  describe 'terms of conditions markdown' do
    it 'parses markdown to HTML on save and saves it into terms_of_use_content_parsed' do
      md_content = "# heading 1\n" \
                   "## heading 2\n" \
                   "Combined emphasis with **asterisks and _underscores_**.\n" \
                   "[I'm an inline-style link](https://www.google.com)"

      html_result = "<h1>heading 1</h1>\n\n" \
                    "<h2>heading 2</h2>\n\n" \
                    "<p>Combined emphasis with <strong>asterisks and <em>underscores</em></strong>.\n" \
                    "<a href=\"https://www.google.com\">I&#39;m an inline-style link</a></p>\n"

      @site.update(terms_of_use_content: md_content)
      @site.save
      @site.reload
      expect(@site.terms_of_use_content_parsed).to eq html_result
    end
  end

  describe 'ai_api_token encryption' do
    it 'stores the token encrypted at rest' do
      @site.update!(ai_api_token: 'super-secret-token')
      raw_value = described_class.connection.select_value(
        "SELECT ai_api_token FROM sites WHERE id = #{@site.id}"
      )
      expect(raw_value).not_to eq('super-secret-token')
      expect(@site.reload.ai_api_token).to eq('super-secret-token')
    end
  end

  describe 'ai_api_base_url validation' do
    it 'accepts a blank url' do
      @site.ai_api_base_url = ''
      expect(@site).to be_valid
    end

    it 'accepts a valid http(s) url' do
      @site.ai_api_base_url = 'https://api.example.com/v1'
      expect(@site).to be_valid
    end

    it 'rejects a malformed url' do
      @site.ai_api_base_url = 'not a url'
      expect(@site).not_to be_valid
    end
  end
end
