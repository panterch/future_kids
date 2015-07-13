class PrincipalSchoolRelation < ActiveRecord::Base
	belongs_to :principals
	belongs_to :schools
end
