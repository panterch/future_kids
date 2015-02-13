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

  def show # not supported action
    redirect_to edit_kid_review_url(resource.kid, resource)
  end

  def index # not supported action
    redirect_to kid_url(parent)
  end
  
  private

  def review_params
    params.require(:review).permit(
      :held_at, :attendee, :reason, :kind, :content, :outcome, :note
    )
  end
end
