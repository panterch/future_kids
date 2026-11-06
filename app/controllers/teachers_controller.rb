# frozen_string_literal: true

class TeachersController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include IndexFilters # filter_index

  before_action :load_and_constrain_schools, except: %i[index show]

  def index
    @teachers = filter_index(@teachers, teacher_params)
    return if performed?

    # with_attached_photo: preload the avatar of every row (users/_list)
    @teachers = @teachers.with_attached_photo

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !(current_user.is_a?(Admin) || current_user.is_a?(Principal)) && @teachers.one?
      redirect_to @teachers.first
    else
      respond_with @teachers
    end
  end

  private

  # admins and principal may change the school of a teacher. we have to make
  # sure that this is only done inside the available schools of the current
  # user - else it would be possible for a user to assign a teacher to
  # another school
  def load_and_constrain_schools
    @schools = case current_user
               when Admin
                 School.by_kind(:teacher)
               when Principal
                 current_user.schools
               else
                 []
               end
    return unless params[:teacher].present? && params[:teacher][:school_id].present?
    return if @schools.map(&:id).include?(params[:teacher][:school_id].to_i)

    raise SecurityError, "User #{current_user.id} not allowed to change school_id to #{params[:teacher][:school_id]}"
  end

  # inactive is write-protected by the global ApplicationController guard,
  # not by role-conditional permitting here
  def teacher_params
    if params[:teacher].present?
      params.require(:teacher).permit(:name, :prename, :email, :password, :password_confirmation, :school_id,
                                       :phone, :receive_journals, :todo, :note, :inactive, :photo)
    else
      {}
    end
  end
end
