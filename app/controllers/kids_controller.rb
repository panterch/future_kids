class KidsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  before_filter :assign_current_teacher, :only => [:create, :update]

  def index
    return redirect_to collection.first if (1 == collection.count)
    index!
  end

protected

  # when the user working on the kid is a teacher, it get's unconditionally
  # assigned as the first teacher of the kid
  def assign_current_teacher
    return true unless current_user.is_a?(Teacher)
    resource.teacher = current_user
  end

end
