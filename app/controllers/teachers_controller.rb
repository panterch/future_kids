class TeachersController < ApplicationController
  load_and_authorize_resource
  include CrudActions

  before_action :load_and_constrain_schools, except: [:index, :show]
  # principals are allowed to change teachers schools, so we cannot
  # use the too aggressive global parameter filtering
  skip_before_action :intercept_sensitive_params!


  def index
    # a prototyped teacher is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:teacher] ||= {}
    params[:teacher][:inactive] = '0' if params[:teacher][:inactive].nil?

    @teachers = @teachers.where(teacher_params.to_h.delete_if { |_key, val| val.blank? })

    @teacher = Teacher.new(teacher_params)

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !(current_user.is_a?(Admin) || current_user.is_a?(Principal)) && (1 == @teachers.count)
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
    case current_user
      when Admin
        @schools = School.by_kind(:teacher)
      when Principal
        @schools = current_user.schools
      else
        @schools = []
    end
    return unless params[:teacher].present? && params[:teacher][:school_id].present?
    unless @schools.map(&:id).include?(params[:teacher][:school_id].to_i)
      fail SecurityError.new("User #{current_user.id} not allowed to change school_id to #{params[:teacher][:school_id]}")
    end
  end

  def teacher_params
    if params[:teacher].present?
      keys = [ :name, :prename, :email, :password, :password_confirmation, :school_id,
          :phone, :receive_journals, :todo, :note]
      keys << :inactive if current_user.is_a?(Admin)
      keys = keys & current_ability.permitted_attributes(:update, Teacher)

      params.require(:teacher).permit(keys)
    else
      {}
    end
  end
end
