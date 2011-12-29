class TeachersController < InheritedResources::Base
  load_and_authorize_resource

  def index
    if params[:teacher]
      @teachers = @teachers.where(params[:teacher].delete_if {|key, val| val.blank? })
    end
    @teacher = Kid.new(params[:teacher])
    index!
  end

end
