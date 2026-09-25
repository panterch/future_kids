# frozen_string_literal: true

# Public page (linked from the footer, also on the login page) showing the
# terms of use maintained in the site settings
class TermsOfUseController < ApplicationController
  skip_before_action :authenticate_user!
  skip_authorization_check

  def show
    head :not_found if @site.terms_of_use_content.blank?
  end
end
