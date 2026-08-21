# frozen_string_literal: true

# raises if a non-admin submits an attribute that CanCanCan's record-level
# authorization does not restrict (e.g. mentor/admin assignment, exit status)
module PrivilegedFieldGuard
  extend ActiveSupport::Concern

  included do
    class_attribute :privileged_field_guards, default: []
  end

  class_methods do
    # param_root: the top-level params key to check (e.g. :kid), or nil to
    # search the whole params tree (used for fields sensitive on every
    # controller, such as :inactive). Guards accumulate across the
    # inheritance chain, so ApplicationController's global guards still run
    # alongside any a subclass registers.
    def guards_privileged_fields(param_root, fields)
      self.privileged_field_guards += [[param_root, fields]]
    end
  end

  def intercept_privileged_fields
    return true unless %w[update create].include?(action_name)
    return if current_user.is_a?(Admin)

    privileged_field_guards.each do |param_root, fields|
      scope = param_root ? params[param_root] : params
      next if scope.blank?

      submitted = fields.select { |field| params_key_present?(scope, field) }
      next if submitted.empty?

      raise SecurityError, "User #{current_user.id} not allowed to change #{submitted.join(', ')}"
    end
  end

  private

  def params_key_present?(scope, key)
    case scope
    when ActionController::Parameters, Hash
      return true if scope.key?(key)

      scope.values.any? { |value| params_key_present?(value, key) }
    when Array
      scope.any? { |value| params_key_present?(value, key) }
    else
      false
    end
  end
end
