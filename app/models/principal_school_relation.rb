# frozen_string_literal: true

class PrincipalSchoolRelation < ApplicationRecord
  belongs_to :principal
  belongs_to :school
end
