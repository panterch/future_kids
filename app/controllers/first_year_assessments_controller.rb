class FirstYearAssessmentsController < ApplicationController
  load_and_authorize_resource :kid
  load_and_authorize_resource :first_year_assessment, through: :kid
  include CrudActions

  def new
    @first_year_assessment.initialize_default_values(@kid)
    render :new
  end

  def create
    @first_year_assessment.created_by = current_user
    if @first_year_assessment.save
      respond_with @first_year_assessment.kid
    else
      render :new
    end
  end

  def update
    if @first_year_assessment.update(first_year_assessment_params)
      respond_with @first_year_assessment.kid
    else
      render :edit
    end
  end

  def show # not supported action
    redirect_to edit_kid_first_year_assessment_url(@first_year_assessment.kid, @first_year_assessment)
  end

  def index # not supported action
    redirect_to kid_url(@kid)
  end

  def destroy
    @first_year_assessment.destroy
    respond_with @first_year_assessment.kid
  end

  private

  def first_year_assessment_params
    params.require(:first_year_assessment).permit(
      :held_at, :teacher_id, :mentor_id, :duration,
      :development_teacher, :development_mentor,
      :goals_teacher, :goals_mentor, :relation_mentor, :motivation, :collaboration,
      :breaking_off, :breaking_reason, :goal_1, :goal_2, :goal_3, :improvements,
      :note

    )
  end
end
