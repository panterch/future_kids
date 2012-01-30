class TeachersController < InheritedResources::Base
  load_and_authorize_resource

  def index
    # a prototyped teacher is submitted with each index query. if the prototype
    # is not present, it is built here with default values
    params[:teacher] ||= {}
    params[:teacher][:inactive] = "0" if params[:teacher][:inactive].nil?
    @teachers = @teachers.where(params[:teacher].delete_if {|key, val| val.blank? })

    @teacher = Kid.new(params[:teacher])

    # when only one record is present, show it immediatelly. this is not for
    # admins, since they could have no chance to alter their filter settings in
    # some cases
    if !current_user.is_a?(Admin) && (1 == collection.count)
      redirect_to collection.first 
    else
      index!
    end
  end

end
