class SchoolsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def create
    create!{ schools_url }
  end

  def update
    update!{ schools_url }
  end

end
