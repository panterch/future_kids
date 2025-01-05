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
      resource.send(field)&.display_name
    end
  end

  # values for the collection select 'sex'
  def sex_collection
    { 'weiblich' => 'f', 'männlich' => 'm', 'divers' => 'd' }
  end

  def transport_collection
    %w(Halbtax GA Zone\ 10\ mit\ Halbtax Zone\ 10\ ohne\ Halbtax ZVV\ Netzpass Regenbogen\ Kanton)
  end

  def boolean_collection
    { 'Ja' => true, 'Nein' => false }
  end

  def term_collection
    (@site.term_collection_start..@site.term_collection_end)
      .reduce([]) { |ar, year| ar << "#{year} Frühling" << "#{year} Herbst" }
  end

  def ects_collection
    Mentor.ects.keys.map { |key| [ I18n.t(key, scope: :ects), key] }
  end

  def exit_reason_collection
    ['Übertritt',
     'Wegzug',
     'Erfolgreich abgeschlossen',
     'Nicht geeignete Massnahme',
     'Andere Gründe']
  end

  def exit_kind_collection
    %w(exit later continue_term continue).map { |i| [I18n.t(i, scope: 'exit_kind'), i] }
  end

  def school_collection
    School.all.map { |s| [s.display_name, s.id] }
  end

  def school_collection_by_kind(role)
    schools = School.by_kind(role)
    return [] unless schools
    schools.map { |s| [s.display_name, s.id] }
  end

  def admin_collection
    Admin.active.map { |a| [a.display_name, a.id] }
  end

  # collection suitable for select form fields
  # returns all active teachers or if kid is given teachers of the kid itself
  def mentor_collection(kid = nil)
    if kid
      collection = [ kid.mentor, kid.secondary_mentor].compact
    else
      collection = Mentor.active
    end
    collection.map { |m| [m.display_name, m.id] }
  end

  def teacher_collection(kid = nil)
    if kid
      collection = [ kid.teacher, kid.secondary_teacher, kid.third_teacher].compact
    else
      collection = Teacher.active
    end
    collection.map { |t| [t.display_name, t.id] }
  end

  def kid_collection
    collection = Kid.active
    collection.map { |k| [k.display_name, k.id] }
  end

  def order_by_collection_for_kids(selected, distance = false)
    options = [%w[Name name],
               %w[Kontrolldatum checked_at],
               %w[Coachingdatum coached_at],
               %w[Erfassungsdatum created_at],
               %w[Kritikalität abnormality_criticality]]
    options << %w[Entfernung distance] if distance
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

  def grade_group_collection(selected)
    options = [%w[Unterstufe 1-3],
               %w[Mittelstufe 4-6]]
    options_for_select(options, selected)
  end

  def distance_from_collection(selected)
    options = [['meinem Wohnort', 'mentor'],
               ['Zürich HB', 'zurich']]
    options_for_select(options, selected)
  end

  def criticality_collection
    (1..3).map { |i| [I18n.t(i, scope: 'kids.criticality'), i] }
  end

  def duration_collection
    [
        ['30 Minuten', 30],
        ['1 Stunde', 60],
        ['1½ Stunden', 90],
        ['2 Stunden', 120]
    ]
  end

  def trinary_collection
    %w(yes no partially).map { |s| [I18n.t(s, scope: 'trinary'), s] }
  end

  def quaternary_collection
    %w(yes mostly partially no).map { |s| [I18n.t(s, scope: 'quaternary'), s] }
  end

  def kind_collection
    ['bei Familie zu Hause',
     'in der Schule',
     'telefonisch',
     'Mail']
  end

  def reason_collection
    ['Ersttreffen',
     'Schulbesuch',
     'Telefoncoaching',
     'Auswertungsgespräch',
     'Weiteres']
  end

  def meeting_type_collection
    Journal.meeting_types.keys.map { |s| [Journal.humanize_enum('meeting_type', s), s] }
  end

  def school_kind_collection
    School.school_kinds.keys.map { |s| [School.humanize_enum('school_kind', s), s] }
  end

  def mentor_matching_state_collection
    MentorMatching.states.transform_keys { |s| MentorMatching.human_state_name(s) }
  end

  # can be used in view to display private data only to their owners (and
  # admins)
  def is_viewing_own_data(resource)
    current_user == resource || current_user.is_a?(Admin)
  end

  # determines style class of scheduler cells
  def schedule_class(schedule)
    schedule.is_last_meeting? ? 'info' : ''
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

  # renders a title inside the form, aligned with form fields
  def form_subtitle(text)

    html = tag.label class: %w(string col-sm-3 control-label)

    html += tag.div class: %w( col-sm-9 ) do
      tag.p tag.strong text
    end

    html
  end

  # renders the label of a boolean field when it is set fitting into
  # a show_for context
  def conditionally_show_for(obj, field)
    return unless obj[field]
    tag.div class: %w( col-sm-offset-3 col-xs-offset-3 ) do
      I18n.t("activerecord.attributes.#{obj.model_name.to_s.downcase}.#{field}")
    end
  end

  def human_date(date)
    return nil unless date.present?
    I18n.l(date)
  end

  def human_distance(distance)
    "#{distance.round(2)} km"
  end

  # returns the page description translation key of the format
  #
  # page_description.controller.action.user_type
  #
  # user_type is optional
  def page_description
    d = I18n.t("page_description.#{controller_name}.#{action_name}")
    if d.is_a? Hash
      return d[current_user.type.downcase.to_sym]
    else
      return d
    end
  end

  def available_kid_actions(kid)
    mentor_matching = kid.mentor_matching_for(current_user)
    actions = []
    if can? :create, MentorMatching
      if kid.match_available?(current_user)
        actions << link_to('Mentoringanfrage senden', new_mentor_matching_path(kid_id: kid), class: 'btn btn-default btn-xs')
      else
        if can? :confirm, mentor_matching
          actions << link_to(I18n.t(:confirm, scope: 'crud.action'), confirm_mentor_matching_path(mentor_matching), method: :put, class: 'btn btn-success btn-xs')
        end
        if can? :decline, mentor_matching
          actions << link_to(I18n.t(:decline, scope: 'crud.action'), decline_mentor_matching_path(mentor_matching), method: :put, class: 'btn btn-danger btn-xs')
        end
        if can? :read, mentor_matching
          actions << link_to(I18n.t(:show, scope: 'crud.action'), mentor_matching, class: 'btn btn-default btn-xs')
        end
        if actions.blank?
          actions << mentor_matching.human_state_name
        end
      end
    end
    actions.join(' ')
  end
end
