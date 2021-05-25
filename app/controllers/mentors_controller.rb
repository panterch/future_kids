class MentorsController < ApplicationController
  load_and_authorize_resource
  include CrudActions
  include ManageSchedules # edit_schedules & update_schedules

  before_action :load_schools, except: [:index]

  def index
    # a prototyped mentor is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:mentor] ||= {}
    params[:mentor][:inactive] = '0' if params[:mentor][:inactive].nil?

    # mentors are filtered by the criteria above
    last_selected_coach = params[:mentor][:filter_by_coach_id]
    last_selected_meeting_day = params[:mentor][:filter_by_meeting_day]
    last_selected_school = params[:mentor][:filter_by_school_id]
    unless params[:mentor][:filter_by_coach_id].blank?
      @mentors = @mentors.joins(:admins).where('kids.admin_id = ?', params[:mentor][:filter_by_coach_id].to_i).distinct
      params[:mentor][:filter_by_coach_id] = nil
    end
    unless params[:mentor][:filter_by_meeting_day].blank?
      @mentors = @mentors.joins(:kids).where('kids.meeting_day = ?', params[:mentor][:filter_by_meeting_day].to_i).distinct
      params[:mentor][:filter_by_meeting_day] = nil
    end
    unless params[:mentor][:filter_by_school_id].blank?
      @mentors = @mentors.joins(:schools).where('kids.school_id = ?', params[:mentor][:filter_by_school_id].to_i).distinct
      params[:mentor][:filter_by_school_id] = nil
    end
    @mentors = @mentors.where(mentor_params.to_h.delete_if { |_key, val| val.blank? })
    params[:mentor][:filter_by_coach_id] = last_selected_coach
    params[:mentor][:filter_by_meeting_day] = last_selected_meeting_day
    params[:mentor][:filter_by_school_id] = last_selected_school

    # provide a prototype for the filter form
    @mentor = Mentor.new(mentor_params)


    if current_user.is_a?(Admin) && 'xlsx' == params[:format]
      return render xlsx: 'index'
    # when only one record is present, show it immediately. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    elsif !current_user.is_a?(Admin) && (1 == @mentors.count)
      redirect_to @mentors.first
    else
      respond_with @mentors
    end
  end

  def show
    # together with the mentor, a list of journal entries is shown for the
    # given year / month
    @year =  (params[:year] || Date.today.year).to_i
    @month = (params[:month] || Date.today.month).to_i
    @journals = @mentor.journals.where(month: @month, year: @year)

    # decouple journals from database to allow adding the virtual record
    # below and use Enumerables sum instead of ARs sum in view
    @journals = @journals.to_a

    # per default a coaching entry is added for each month
    @journals << Journal.coaching_entry(@mentor, @month, @year)
    respond_with @mentor
  end

  def update
    # resend password button
    if params[:commit] == I18n.t('mentors.form.resend_password.btn_text')
      SelfRegistrationsMailer.reset_and_send_password(@mentor).deliver_now
      respond_with @mentor, notice: I18n.t('mentors.form.resend_password.sent_successfully')
      return
    end
    # switched to accepted state
    if mentor_params[:state] == 'accepted' && @mentor.state != mentor_params[:state]
      SelfRegistrationsMailer.reset_and_send_password(@mentor).deliver_now
    end

    super
  end

  def resend_password
    SelfRegistrationsMailer.reset_and_send_password(@mentor).deliver_now
  end

  def disable_no_kids_reminder
    @mentor.update_column(:no_kids_reminder, false)
    redirect_to @mentor
  end

  private

  def mentor_params
    if params[:mentor].present?
      p = [:name, :prename, :email, :password, :password_confirmation, :address, :sex,
        :city, :dob, :phone, :school_id, :field_of_study, :education, :transport,
        :personnel_number, :ects, :term, :absence, :note, :todo, :substitute,
        :filter_by_school_id, :filter_by_meeting_day, :filter_by_coach_id,
        :exit_kind, :exit_at, :no_kids_reminder,
        :inactive, :photo, schedules_attributes: [:day, :hour, :minute]
      ]
      p << :state if can? :update, Mentor, :state

      if params[:mentor][:state] && !(can? :update, Mentor, :state)
        fail SecurityError.new("User #{current_user.id} not allowed to change its state")
      end

      params.require(:mentor).permit(*p)
    else
      {}
    end
  end

  def load_schools
    @schools = School.by_kind(:mentor)
    @schools_include_blank = true
  end
end
