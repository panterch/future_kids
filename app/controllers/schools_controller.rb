# frozen_string_literal: true

class SchoolsController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  def index
    filter = school_filter_params
    @schools = apply_school_filter(@schools, filter)
    @active_kids_counts = Kid.active.reorder(nil).where(school_id: @schools).group(:school_id).count
    @schools = @schools.includes(:teachers, { principal_school_relations: :principal })
    @school = School.new(filter)
    respond_with @schools
  end

  def create
    @school = School.new(school_params)
    if @school.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def update
    if @school.update(school_params)
      redirect_to action: :index
    else
      render :edit
    end
  end

  private

  def apply_school_filter(schools, filter)
    schools.where(
      filter.to_h.delete_if { |key, val| School.column_names.exclude?(key.to_s) || val.blank? }
    )
  end

  def school_filter_params
    return {} if params[:school].blank?

    params.expect(school: %i[school_kind district])
  end

  def school_params
    params.expect(
      school: %i[name school_kind principal_id street city phone homepage social
                 district note term]
    )
  end
end
