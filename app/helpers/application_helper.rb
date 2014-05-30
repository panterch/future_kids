module ApplicationHelper

  # link to the given resource if at least read access is given
  def can_link_to(resource)
    return "" if resource.blank?
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

  def transport_collection
    %w(Halbtax GA Regenbogen\ Kanton Zone\ 10\ mit\ Halbtax Zone\ 10\ ohne\ Halbtax)
  end

  def school_collection
    School.all.map{ |s| [ s.display_name, s.id ]}
  end

  def admin_collection
    Admin.all.map { |a| [a.display_name, a.id] }
  end

  def mentor_collection
    Mentor.active.map { |m| [m.display_name, m.id] }
  end

  def teacher_collection
    Teacher.active.map { |t| [t.display_name, t.id] }
  end

  def term_collection
    ['2011 Frühling', '2011 Herbst',
     '2012 Frühling', '2012 Herbst',
     '2013 Frühling', '2013 Herbst',
     '2014 Frühling', '2014 Herbst',
     '2015 Frühling', '2015 Herbst']
  end

  def exit_reason_collection
    [ "Übertritt",
    "Wegzug",
    "Erfolgreich abgeschlossen",
    "Nicht geeignete Massnahme",
    "Andere Gründe" ]
  end


  def order_by_collection_for_kids(selected)
    options = [['Name', 'name, prename' ],
               ['Kontrolldatum', 'checked_at ASC' ],
               ['Coachingdatum', 'coached_at ASC' ],
               ['Erfassungsdatum', 'created_at ASC' ],
               ['Kritikalität', 'abnormality_criticality']]
    options_for_select(options, selected)
  end

  # values for the collection select 'weekday'
  # weekdays are mapped to integers, as in ruby core's Time, Sunday is 0
  def wday_collection
    (1..5).map{ |i| [I18n.t('date.day_names')[i], i] }
  end

  def grade_collection
    (1..6).to_a.reverse
  end

  def criticality_collection
    (1..3).map{ |i| [I18n.t(i, :scope => 'kids.criticality'), i] }
  end

  # renders a formtastic field that is taken over by the datepicker js
  def date_picker(form, field)
    value = resource[field] ? I18n.l(resource[field]) : nil
    form.input field, :as => :string, :input_html => {
      :value => value, :class => 'calendricalDate'
      }
  end

  # can be used in view to display private data only to their owners (and
  # admins)
  def is_viewing_own_data
    current_user == resource || current_user.is_a?(Admin)
  end

  # determines style class of scheduler cells
  def schedule_class(schedule)
    return nil unless @mentor_schedules
    @mentor_schedules.each do |tag, schedules|
      next unless schedules.include?(schedule)
      return 'highlight'
    end
    ''
  end

  def schedule_tags(schedule)
    return [] unless @mentor_schedules
    tags = []
    @mentor_schedules.each do |tag, schedules|
      next unless schedules.include?(schedule)
      tags << tag
    end
    tags
  end

  def todo_content(resource)
    markup = resource.human_todo
    markup += link_to 'edit', edit_resource_path(resource, :anchor => 'todo')
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''
    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end
end
