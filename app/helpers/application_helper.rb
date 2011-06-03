module ApplicationHelper

  # link to the given resource if at least read access is given
  def can_link_to(resource)
    return "" if resource.nil?
    return resource.display_name if cannot?(:read, resource)
    link_to resource.display_name, resource
  end

  # display a form field or a read only field, depending on the abilities
  # of the current user
  def can_select(form, field, clazz)
    if can? :manage, clazz
      form.collection_select(field, clazz.accessible_by(@current_ability),
                             :id, :display_name, {:include_blank => true})
    else
      field = field[0...-3] # remove _id from field
      resource.send(field).try(:display_name)
    end
  end

end
