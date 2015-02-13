class SchoolsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  def create
    create!{ schools_url }
  end

  def update
    update!{ schools_url }
  end

  private

  def school_params
    params.require(:school).permit(
      :name, :principal_id, :street, :city, :phone, :homepage, :social,
      :district, :note, :term
    )
  end
end
