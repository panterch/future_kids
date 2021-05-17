class AvailableKidsController < ApplicationController
  load_and_authorize_resource class: Kid

  def index
    @kids = Kid.select("*, #{Kid.distance_sql(current_user)} as distance").accessible_by(current_ability, :search)
  end
end
