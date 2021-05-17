class AvailableKidsController < ApplicationController
  load_and_authorize_resource class: Kid

  def index
    @kids = Kid.select("*, #{Kid.distance_sql(current_user)} as distance").accessible_by(current_ability, :search)
    if (grade_group = params['grade_group']) && valid_grade_group?(grade_group)
      @kids = @kids.where(grade: Range.new(*grade_group.split('-').map(&:to_i)).to_a)
    end
  end
end
