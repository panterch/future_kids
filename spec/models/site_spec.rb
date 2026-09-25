# frozen_string_literal: true

require 'spec_helper'

describe Site do
  before do
    @site = described_class.load
  end

  describe '#terms_of_use_html' do
    it 'renders the markdown terms of use as HTML' do
      md_content = "# heading 1\n" \
                   "## heading 2\n" \
                   "Combined emphasis with **asterisks and _underscores_**.\n" \
                   "[I'm an inline-style link](https://www.google.com)"

      html_result = "<h1>heading 1</h1>\n\n" \
                    "<h2>heading 2</h2>\n\n" \
                    "<p>Combined emphasis with <strong>asterisks and <em>underscores</em></strong>.\n" \
                    "<a href=\"https://www.google.com\">I&#39;m an inline-style link</a></p>\n"

      @site.terms_of_use_content = md_content
      expect(@site.terms_of_use_html).to eq html_result
    end

    it 'escapes raw HTML and drops javascript: links' do
      @site.terms_of_use_content = "<script>alert(1)</script>\n\n[click](javascript:alert(1))"
      html = @site.terms_of_use_html
      expect(html).not_to include('<script>')
      expect(html).to include('&lt;script&gt;')
      expect(html).not_to include('href="javascript:')
    end

    it 'is nil without terms of use' do
      @site.terms_of_use_content = ''
      expect(@site.terms_of_use_html).to be_nil
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
