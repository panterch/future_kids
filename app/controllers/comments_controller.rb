class CommentsController < ApplicationController
  before_action :prepare_journal

  def new
    @comment = @journal.comments.build
    @comment.initialize_default_values(current_user)
    authorize! :create, @comment
  end

  def create
    @comment = @journal.comments.build(comment_params)
    @comment.created_by = current_user
    authorize! :create, @comment
    if @comment.save
      redirect_to kid_url(id: @journal.kid_id)
    else
      render :new
    end
  end

  def edit
    @comment = @journal.comments.find(params[:id])
    authorize! :update, @comment
  end

  def update
    @comment = @journal.comments.find(params[:id])
    authorize! :update, @comment
    if @comment.update(comment_params)
      redirect_to kid_url(id: @journal.kid_id)
    else
      render :edit
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
        # don't add created_by here - it is set by the controller directly for security reasons
        :by, :body, :to_teacher, :to_secondary_teacher, :to_third_teacher
      )
    else
      {}
    end
  end
end
