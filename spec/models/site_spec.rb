require 'spec_helper'

describe Site do
    before do 
        @site = Site.load
    end

    describe "terms of conditions markdown" do
        it "parses markdown to HTML on save and saves it into terms_of_use_content_parsed" do
            md_content = "# heading 1\n"\
                "## heading 2\n"\
                "Combined emphasis with **asterisks and _underscores_**.\n"\
                "[I'm an inline-style link](https://www.google.com)"

            html_result = "<h1>heading 1</h1>\n\n"\
            "<h2>heading 2</h2>\n\n"\
            "<p>Combined emphasis with <strong>asterisks and <em>underscores</em></strong>.\n"\
            "<a href=\"https://www.google.com\">I&#39;m an inline-style link</a></p>\n"

            @site.update(terms_of_use_content: md_content)
            @site.save
            @site.reload
            expect(@site.terms_of_use_content_parsed).to eq html_result
        end
    end
end