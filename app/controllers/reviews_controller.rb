class ReviewsController < ApplicationController
  load_and_authorize_resource :kid
  load_and_authorize_resource :review, through: :kid
  include CrudActions

  def create
    if @review.save
      respond_with @review.kid
    else
      render :new
    end
  end

  def update
    if @review.update(review_params)
      respond_with @review.kid
    else
      render :edit
    end
  end

  def show # not supported action
    redirect_to edit_kid_review_url(@review.kid, @review)
  end

  def index # not supported action
    redirect_to kid_url(@kid)
  end

  def destroy
    @review.destroy
    respond_with @review.kid
  end

  private

  def review_params
    params.require(:review).permit(
      :held_at, :attendee, :reason, :kind, :content, :outcome, :note
    )
  end
end
