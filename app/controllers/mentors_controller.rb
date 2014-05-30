class MentorsController < ApplicationController

  inherit_resources
  load_and_authorize_resource
  include ManageSchedules # edit_schedules & update_schedules

  def index
    # a prototyped mentor is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:mentor] ||= {}
    params[:mentor][:inactive] = "0" if params[:mentor][:inactive].nil?

    # mentors are filtered by the criteria above
    @mentors = @mentors.where(params[:mentor].delete_if {|key, val| val.blank? })

    # provide a prototype for the filter form
    @mentor = Mentor.new(permitted_params[:mentor])

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
end
