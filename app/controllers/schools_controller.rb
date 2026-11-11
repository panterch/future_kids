# frozen_string_literal: true

class SchoolsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index

  def index
    @schools = filter_index(@schools, school_params)
    return if performed?

    @active_kids_counts = Kid.active.reorder(nil).where(school_id: @schools).group(:school_id).count
    @schools = @schools.includes(:teachers, { principal_school_relations: :principal })
    respond_with @schools
  end

  def create
    @school = School.new(school_params)
    if @school.save
      respond_with @school, location: schools_path
    else
      render :new
    end
  end

  def update
    if @school.update(school_params)
      respond_with @school, location: schools_path
    else
      render :edit
    end
  end

  private

  def school_params
    return {} if params[:school].blank?

    params.expect(
      school: %i[name school_kind principal_id street city phone homepage social
                 district note term inactive]
    )
  end
end
