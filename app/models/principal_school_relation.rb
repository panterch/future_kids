class PrincipalSchoolRelation < ApplicationRecord
  belongs_to :principal
  belongs_to :school
end
