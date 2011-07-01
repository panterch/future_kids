class MentorsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def index
    return redirect_to collection.first if (1 == collection.count)
    index!
  end

end
