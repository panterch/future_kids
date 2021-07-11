class AvailableKidsController < ApplicationController
  def index
    @kids = Kid.accessible_by(current_ability, :search).preload(:mentor_matchings)

    if (grade_group = params['grade_group']) && valid_grade_group?(grade_group)
      @kids = @kids.where(grade: Range.new(*grade_group.split('-').map(&:to_i)).to_a)
    end
    if (distance_from = params['distance_from']) && valid_distance_from?(distance_from) && distance_from != 'mentor'
      distance_from_object = OpenStruct.new(latitude: 47.378169, longitude: 8.540178)
    else
      distance_from_object = current_user
    end
    @kids = @kids.select("*, #{Kid.distance_sql(distance_from_object)} as distance")
    @kids = @kids.reorder('distance ASC')
  end
end
