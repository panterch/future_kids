class PrincipalSchoolRelation < ActiveRecord::Base
  belongs_to :principal
  belongs_to :school
end
