class MentorsController < ApplicationController

  inherit_resources
  load_and_authorize_resource
  include ManageSchedules # edit_schedules & update_schedules

  def index
    # filter mentors with additional criterias if any
    if params[:mentor]
      @mentors = @mentors.where(params[:mentor].delete_if {|key, val| val.blank? })
    end
    # provide a prototype mentor for the filter form
    @mentor = Mentor.new(params[:mentor])
    return redirect_to collection.first if (1 == collection.count)
    index!
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

protected

end
