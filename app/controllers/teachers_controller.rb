class TeachersController < ApplicationController

  load_and_authorize_resource
  include CrudActions

  def index
    # a prototyped teacher is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:teacher] ||= {}
    params[:teacher][:inactive] = "0" if params[:teacher][:inactive].nil?

    @teachers = @teachers.where(teacher_params.to_h.delete_if {|key, val| val.blank? })

    @teacher = Teacher.new(teacher_params)

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !current_user.is_a?(Admin) && (1 == @teachers.count)
      redirect_to @teachers.first
    else
      respond_with @teachers
    end
  end

  private

  def teacher_params
    if params[:teacher].present?
      params.require(:teacher).permit(
        :name, :prename, :email, :password, :password_confirmation, :school_id,
        :phone, :receive_journals, :todo, :note, :inactive
      )
    else
      {}
    end
  end
end
