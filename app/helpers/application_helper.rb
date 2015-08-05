module ApplicationHelper
  # link to the given resource if at least read access is given
  def can_link_to(resource)
    return '' if resource.blank?
    return resource.display_name if cannot?(:read, resource)
    link_to resource.display_name, resource
  end

  # display a form field or a read only field, depending on the abilities
  # of the current user
  def can_select(form, field, clazz)
    if can? :manage, clazz
      form.collection_select(field, clazz.accessible_by(@current_ability),
                             :id, :display_name, include_blank: true)
    else
      field = field[0...-3] # remove _id from field
      resource.send(field).try(:display_name)
    end
  end

  # values for the collection select 'sex'
  def sex_collection
    { 'Mädchen' => 'f', 'Knabe' => 'm' }
  end

  def transport_collection
    %w(Halbtax GA Regenbogen\ Kanton Zone\ 10\ mit\ Halbtax Zone\ 10\ ohne\ Halbtax)
  end

  def boolean_collection
    { 'Ja' => true, 'Nein' => false }
  end

  def term_collection
    (@site.term_collection_start..@site.term_collection_end)
      .reduce([]) { |ar, year| ar << "#{year} Frühling" << "#{year} Herbst" }
  end

  def exit_reason_collection
    ['Übertritt',
     'Wegzug',
     'Erfolgreich abgeschlossen',
     'Nicht geeignete Massnahme',
     'Andere Gründe']
  end

  def exit_kind_collection
    %w(exit later continue).map { |i| [I18n.t(i, scope: 'exit_kind'), i] }
  end

  def school_collection
    School.all.map { |s| [s.display_name, s.id] }
  end

  def admin_collection
    Admin.active.map { |a| [a.display_name, a.id] }
  end

  def mentor_collection
    Mentor.active.map { |m| [m.display_name, m.id] }
  end

  def teacher_collection
    Teacher.active.map { |t| [t.display_name, t.id] }
  end

  def order_by_collection_for_kids(selected)
    options = [['Name', 'name, prename'],
               ['Coachingdatum', 'coached_at ASC'],
               ['Erfassungsdatum', 'created_at ASC'],
               %w(Kritikalität abnormality_criticality)]
    options_for_select(options, selected)
  end

  def order_by_collection_for_kid_mentor_relations(selected)
    options = [[Kid.model_name.human, 'kid_name'],
               [Mentor.model_name.human, 'mentor_name']]
    options_for_select(options, selected)
  end

  # values for the collection select 'weekday'
  # weekdays are mapped to integers, as in ruby core's Time, Sunday is 0
  def wday_collection
    (1..5).map { |i| [I18n.t('date.day_names')[i], i] }
  end

  def grade_collection
    (1..6).to_a.reverse
  end

  def criticality_collection
    (1..3).map { |i| [I18n.t(i, scope: 'kids.criticality'), i] }
  end

  # can be used in view to display private data only to their owners (and
  # admins)
  def is_viewing_own_data(resource)
    current_user == resource || current_user.is_a?(Admin)
  end

  # determines style class of scheduler cells
  def schedule_class(schedule)
    return nil unless @mentor_schedules
    @mentor_schedules.each do |_tag, schedules|
      next unless schedules.include?(schedule)
      return 'info'
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

  def nav_link(model_name_or_link_text, link_path = nil)
    # convenience interpolation: when a symbol is submitted to
    # this method it tries to automatically extrapolate the link
    # text and path
    if link_path.blank?
      model_name = model_name_or_link_text.to_s
      begin
        # prefer specific menu entries under nav scope and use activerecord
        # model name as fallback
        link_text = I18n.translate!(model_name, scope: :nav)
      rescue I18n::MissingTranslationData
        link_text = I18n.translate(model_name, scope: 'activerecord.models')
      end
      link_path = url_for(controller: model_name.pluralize, action: :index,
                          only_path: true)
    else
      link_text = model_name_or_link_text
    end
    # set classname to active when link corresponds with current page
    # (first test for request is to make testing easier)
    class_name = request && current_page?(link_path) ? 'active' : ''
    content_tag(:li, class: class_name) do
      link_to link_text, link_path
    end
  end

  def human_date(date)
    return nil unless date.present?
    I18n.l(date)
  end
end
