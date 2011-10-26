class ReviewsController < ApplicationController

  inherit_resources
  belongs_to :kid
  load_and_authorize_resource


  def create
    create!{ kid_url(resource.kid) }
  end
  
  def update
    update!{ kid_url(resource.kid) }
  end

  def show
    redirect_to edit_kid_review_url(resource.kid, resource)
  end
  
protected


end
