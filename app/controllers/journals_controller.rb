class JournalsController < ApplicationController

  # this filter has to run before cancan resource loading
  before_filter :preset_mentor, :except => :index

  inherit_resources
  belongs_to :kid
  load_and_authorize_resource

  # these filters have to run after the resource is initialized
  before_filter :prepare_mentor_selection, :only => [:new, :edit], :if => :admin?
  before_filter :preset_held_at, :only => [ :new ]

  def create
    create!{ kid_url(resource.kid) }
  end
  
  def update
    update!{ kid_url(resource.kid) }
  end
  
protected

  # before giving cancan the control over the resource loading we influence
  # the created / built resource by adding some parameters to the params
  # hash
  def preset_mentor
    params[:journal] ||= {}
    # for mentors we overwrite the mentor_id paramenter to assure that they
    # do not create entries for other mentors
    if current_user.is_a?(Mentor)
      params[:journal][:mentor_id] = current_user.id
    end
  end

  # for admins a dropdown to select a mentor is displayed, its data is
  # collected here
  def prepare_mentor_selection
    @mentors = [ resource.kid.mentor, resource.kid.secondary_mentor].compact
    return unless @mentors.empty?
    redirect_to kid_url(resource.kid), :alert => "Bitte vorher einen Mentor zuordnen."
  end

  # the value of the held_at field can be determined by the schedule of the
  # kid
  def preset_held_at
    resource.held_at ||= resource.kid.calculate_meeting_time.try(:to_date)
  end

end
