# frozen_string_literal: true

# raises if a non-admin submits an attribute that CanCanCan's record-level
# authorization does not restrict (e.g. mentor/admin assignment, exit status)
module PrivilegedFieldGuard
  extend ActiveSupport::Concern

  included do
    class_attribute :privileged_field_param_root, :privileged_fields
  end

  class_methods do
    def guards_privileged_fields(param_root, fields)
      self.privileged_field_param_root = param_root
      self.privileged_fields = fields
    end
  end

  def intercept_privileged_fields
    return true unless %w[update create].include?(action_name)
    return if current_user.is_a?(Admin)
    return if params[privileged_field_param_root].blank?

    submitted = privileged_fields.select { |field| params[privileged_field_param_root].key?(field) }
    return if submitted.empty?

    raise SecurityError, "User #{current_user.id} not allowed to change #{submitted.join(', ')}"
  end
end
