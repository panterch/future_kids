class AvailableKidsController < ApplicationController
  load_and_authorize_resource class: Kid

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
    if (order_by = params['order_by']) && (order_by == 'distance' || valid_order_by?(Kid, params['order_by']))
      @kids = @kids.reorder(params['order_by'])
    end
  end
end
