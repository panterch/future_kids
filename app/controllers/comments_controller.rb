class CommentsController < ApplicationController

  before_filter :prepare_journal

  def new
    @comment = @journal.comments.build
    @comment.initialize_default_values(current_user)
  end

  def create
    @comment = @journal.comments.build(params[:comment])
    if @comment.save
      redirect_to kid_url(:id => @journal.kid_id)
    else
      render :new
    end
  end

private

  def prepare_journal
    @journal = Journal.find(params[:journal_id])
    # all users that can read a journal, may comment on it. there are no other
    # special security constraints on comments.
    authorize! :read, @journal
  end

  def permitted_params
    params.permit(:school => [:name, :principal_id, :street, :city, :phone, :homepage, :social, :district, :note, :term])
  end
end
