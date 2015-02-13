class MentorsController < ApplicationController

  inherit_resources
  load_and_authorize_resource
  include ManageSchedules # edit_schedules & update_schedules

  before_filter :accessible_by_error_quick_fix

  def index

    if current_user.is_a?(Admin) && 'xlsx' == params[:format]
      return render xlsx: 'index'
    end

    # a prototyped mentor is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    mentor_params[:inactive] = "0" if mentor_params[:inactive].nil?

    # mentors are filtered by the criteria above
    @mentors = @mentors.where(mentor_params.to_h.delete_if {|key, val| val.blank? })

    # provide a prototype for the filter form
    @mentor = Mentor.new(mentor_params)

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !current_user.is_a?(Admin) && (1 == collection.count)
      redirect_to collection.first
    else
      index!
    end
  end

  def show
    # together with the mentor, a list of journal entries is shown for the
    # given year / month
    @year =  (params[:year] || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i
    @journals = @mentor.journals.where(:month => @month, :year => @year)

    # decouble journals from database to allow adding the virtial record
    # below and use Enumerables sum instaed of ARs sum in view
    @journals = @journals.to_a

    # per default a coaching entry is added for each month
    @journals << Journal.coaching_entry(@mentor, @month, @year)
    show!
  end

  private

  def mentor_params
    if params[:mentor].present?
      params.require(:mentor).permit(
        :name, :prename, :email, :password, :password_confirmation, :address,
        :city, :dob, :phone, :college, :field_of_study, :education, :transport,
        :personnel_number, :ects, :term, :absence, :note, :todo, :substitute,
        :inactive, :photo, schedules_attributes: [:day, :hour, :minute]
      )
    else
      {}
    end
  end
end
