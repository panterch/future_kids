# frozen_string_literal: true

# CanCan::AccessDenied is rescued in ApplicationController and turned into
# a redirect to the root page. This helper keeps the denial assertions in
# controller specs concise.
module AccessDeniedHelper
  def expect_access_denied
    yield
    expect(response).to redirect_to(root_url)
    expect(flash[:alert]).to eq(I18n.t('flash.access_denied'))
  end
end

RSpec.configure do |config|
  config.include AccessDeniedHelper, type: :controller
end
