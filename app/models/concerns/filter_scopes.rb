# frozen_string_literal: true

# Filters of an index filter bar that are no column of the model (e.g. the
# mentors coaching a certain kid). Each is a scope named like its param,
# applied by IndexFilters#filter_index when the param is present:
#
#   filter_scope :filter_by_coach_id, ->(id) { joins(:admins).where(...) }
#
# The accessor of the same name lets the filter bar's prototype record
# (e.g. Mentor.new(mentor_params)) take and show the value. Only scopes
# registered here are ever called with a param - the name never comes from
# the request.
module FilterScopes
  extend ActiveSupport::Concern

  included do
    class_attribute :filter_scopes, instance_accessor: false, default: []
  end

  class_methods do
    def filter_scope(name, body)
      scope name, body
      attr_accessor name

      self.filter_scopes += [name.to_s]
    end
  end
end
