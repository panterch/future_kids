RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  # this is a configuration to enable sign_in to work in controller specs even with
  # STI for the user models
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.before(:each, type: :controller) do
    Rails.application.reload_routes!
  end
end
