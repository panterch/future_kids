# frozen_string_literal: true

class TerminationAssessmentsController < ApplicationController
  load_and_authorize_resource :kid
  load_and_authorize_resource :termination_assessment, through: :kid
  include CrudActions

  # not supported action
  def index
    redirect_to kid_url(@kid)
  end

  # not supported action
  def show
    redirect_to edit_kid_termination_assessment_url(@termination_assessment.kid, @termination_assessment)
  end

  def new
    @termination_assessment.initialize_default_values(@kid)
    render :new
  end

  def create
    @termination_assessment.created_by = current_user
    if @termination_assessment.save
      respond_with @termination_assessment.kid
    else
      render :new
    end
  end

  def update
    if @termination_assessment.update(termination_assessment_params)
      respond_with @termination_assessment.kid
    else
      render :edit
    end
  end

  def destroy
    @termination_assessment.destroy
    respond_with @termination_assessment.kid
  end

  private

  def termination_assessment_params
    params.require(:termination_assessment).permit(
      :held_at, :teacher_id,
      :development,
      :goals, :goals_reached, :collaboration,
      :improvements,
      :note
    )
  end
end
