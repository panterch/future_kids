# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# The pages load everything from the app itself: scripts and styles from the
# asset pipeline, photos and the logo through the storage proxy, the fonts are
# vendored. So the browser is told to accept nothing else, which keeps injected
# markup from running script or loading from elsewhere.
#
# The inline scripts of the layout (theme switch, speculation rules) and of
# importmap carry a nonce. rails-ujs reads it from csp_meta_tag for the
# JavaScript answers of the reminders list.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    if Rails.env.production?
      policy.script_src :self
    else
      # development and test load React's development bundle, which is built
      # with eval() (vendor/javascript/react.development.js, see
      # config/importmap.rb); the production bundle has none
      policy.script_src :self, :unsafe_eval
    end
    policy.style_src   :self
    # data: for the icons Bootstrap embeds in its stylesheet
    policy.img_src     :self, :data
    policy.font_src    :self
    policy.connect_src :self
    policy.object_src  :none
    policy.base_uri    :self
    policy.form_action :self
    policy.frame_ancestors :self
  end

  # a new nonce for every response
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
