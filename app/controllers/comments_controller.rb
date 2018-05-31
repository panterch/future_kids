class CommentsController < ApplicationController
  before_action :prepare_journal

  def new
    @comment = @journal.comments.build
    authorize! :create, @comment
    @comment.initialize_default_values(current_user)
  end

  def create
    @comment = @journal.comments.build(comment_params)
    authorize! :create, @comment
    @comment.created_by = current_user
    if @comment.save
      redirect_to kid_url(id: @journal.kid_id)
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

  def comment_params
    if params[:comment].present?
      params.require(:comment).permit(
        :by, :body, :to_teacher, :to_secondary_teacher, :to_third_teacher
      )
    else
      {}
    end
  end
end
