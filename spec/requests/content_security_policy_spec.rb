# frozen_string_literal: true

require 'spec_helper'

# see config/initializers/content_security_policy.rb
describe 'Content security policy' do
  let(:policy) { response.headers['Content-Security-Policy'] }
  let(:nonce) { policy[/'nonce-([^']+)'/, 1] }
  let(:page) { response.parsed_body }

  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: user.password } }
  end

  it 'only accepts what the app serves itself' do
    get new_user_session_path

    expect(policy).to include("default-src 'self'", "style-src 'self'", "object-src 'none'",
                              "form-action 'self'", "frame-ancestors 'self'")
    # 'unsafe-eval' is there outside production only, for React's development bundle
    expect(policy).to match(/script-src 'self' 'unsafe-eval' 'nonce-[^']+'/)
    expect(policy).not_to include('unsafe-inline')
  end

  it 'gives every inline script of a page the nonce of that response' do
    sign_in_as(create(:admin))
    get kids_path

    inline_scripts = page.css('script:not([src])')
    expect(inline_scripts.size).to be >= 3 # theme switch, speculation rules, importmap
    expect(inline_scripts.pluck('nonce')).to all(eq(nonce))
    expect(page.at_css('meta[name="csp-nonce"]')['content']).to eq(nonce)
  end

  it 'has no inline style block or style attribute on a page' do
    sign_in_as(create(:admin))
    get kids_path

    expect(page.css('style')).to be_empty
    expect(page.css('[style]')).to be_empty
  end

  # the policy makes the browser ignore a style attribute, so an element meant
  # to start hidden would show: use the hidden attribute or a class instead
  it 'finds no style attribute in the page templates' do
    templates = Rails.root.glob('app/views/**/*.{haml,erb}').reject { |file| file.to_s.include?('mailer/') }
    with_style = templates.select { |file| file.read.match?(/\bstyle\s*(:|=>|=)\s*['"]/) }

    expect(with_style.map { |file| file.relative_path_from(Rails.root).to_s }).to be_empty
  end

  it 'uses a new nonce for every response' do
    nonces = Array.new(2) do
      get new_user_session_path
      response.headers['Content-Security-Policy'][/'nonce-([^']+)'/, 1]
    end

    expect(nonces.uniq.size).to eq(2)
  end
end
