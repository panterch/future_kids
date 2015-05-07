module AdminOnly
  extend ActiveSupport::Concern

  included do
    before_action :assert_admin
  end

  def assert_admin
    return true if current_user.is_a?(Admin)
    fail SecurityError.new("User #{current_user.id} not allowed use controller")
  end
end
