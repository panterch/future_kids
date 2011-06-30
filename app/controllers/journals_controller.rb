class JournalsController < ApplicationController

  inherit_resources
  load_and_authorize_resource

  before_filter :prepare_associations, :except => :index

  def create
    create!{ kid_url(resource.kid) }
  end
  

  

protected

  def prepare_associations
    # TODO: make sure that mentor can write on selected kid
    resource.kid_id ||= params[:kid_id]
    # TODO: auto-select mentor
  end

end
