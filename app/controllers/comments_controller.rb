class CommentsController < ApplicationController

  before_filter :prepare_journal

  def new
    @comment = @journal.comments.build
    @comment.by ||= current_user.display_name
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

end
