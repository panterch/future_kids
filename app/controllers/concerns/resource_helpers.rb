module ResourceHelpers

  private

  def collection_name
    params[:controller] 
  end

  def resource_name
    collection_name.singularize
  end

  def resource_params
    send("#{resource_name}_params")
  end

  def resource_class
    resource_name.capitalize.constantize
  end

  def alias_as_resource
    @resource = instance_variable_get("@#{resource_name}")
  end
end
