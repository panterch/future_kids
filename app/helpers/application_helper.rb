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

  # values for the collection select 'sex'
  def sex_collection
    { "Mädchen" => 'f', "Knabe" => 'm' }
  end

  # values for the collection select 'weekday'
  # weekdays are mapped to integers, as in ruby core's Time, Sunday is 0
  def wday_collection
    (1..5).map{ |i| [I18n.t('date.day_names')[i], i] }
  end

  # renders a formtastic field that is taken over by the datepicker js
  def date_picker(form, field)
    value = resource[field] ? I18n.l(resource[field]) : nil
    form.input field, :as => :string, :input_html => {
      :value => value, :class => 'calendricalDate'
      }
  end

  def private_block
    if current_user == resource || current_user.is_a?(Admin)
      yield
    end
  end
    

end
