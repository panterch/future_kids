# frozen_string_literal: true

module ApplicationHelper
  # Bootstrap Icons (vendored sprite at app/assets/images/bootstrap-icons.svg,
  # see https://icons.getbootstrap.com/). `name` is a Bootstrap Icons id, e.g.
  # "trash" or "arrow-clockwise".
  def icon(name, css_class: nil)
    content_tag(:svg, class: ['icon-svg', css_class].compact.join(' '),
                       viewBox: '0 0 16 16', xmlns: 'http://www.w3.org/2000/svg', 'aria-hidden': true) do
      tag.use(href: "#{asset_path('bootstrap-icons.svg')}##{name}")
    end
  end

  # Icon followed by its label, the content of most buttons and nav links.
  def icon_text(name, text)
    icon(name) + ' ' + text
  end

  # Flash message as a dismissible alert (see #flash in the layout). Maps the
  # Rails flash types onto Bootstrap's contextual alert names.
  def flash_alert(content, type)
    type = { 'alert' => 'danger', 'notice' => 'info' }.fetch(type.to_s, type.to_s)
    icon_name = case type
                when 'danger', 'warning' then 'exclamation-triangle'
                when 'success' then 'check-circle'
                else 'info-circle'
                end
    tag.div(class: "alert alert-#{type} alert-dismissible fade show") do
      tag.button(type: 'button', class: 'btn-close', data: { bs_dismiss: 'alert' }, aria: { label: 'Schliessen' }) +
        icon_text(icon_name, content)
    end
  end

  # renders form.button :submit (or the given block) aligned under the
  # field column of the horizontal_form simple_form wrapper (see
  # simple_form.rb), instead of flush with the label column
  def horizontal_form_actions(form, &block)
    content_tag(:div, class: 'row') do
      content_tag(:div, class: 'col-sm-9 offset-sm-3') do
        block_given? ? capture(&block) : form.button(:submit)
      end
    end
  end

  # link to the given resource if at least read access is given
  def can_link_to(resource)
    return '' if resource.blank?
    return resource.display_name if cannot?(:read, resource)

    link_to resource.display_name, resource
  end

  def sex_collection
    Kid.sexes.keys.map { |k| [Kid.humanize_enum('sex', k), k] }
  end

  def transport_collection
    ['Halbtax', 'GA', 'Zone 10 mit Halbtax', 'Zone 10 ohne Halbtax', 'ZVV Netzpass', 'Regenbogen Kanton']
  end

  # Current path (not url_for, which resolves kids#index to the root route)
  # with the given query params -- used by the filter dropdown links
  # (application/_filter_dropdown), which rebuild the current query string
  # with a single filter changed.
  def filter_path(query)
    "#{request.path}?#{query.to_h.to_query}"
  end

  # Whether the request filters the index of +record+ (the prototype built
  # from params[<param_key>]): any of those params left it different from an
  # unfiltered prototype. Compares the typecast attributes, so an explicit
  # "Nein" (false) counts while "Alle" ('') and the default "Aktiv" (false,
  # whether sent as 'false' or '0') don't.
  def filters_active?(record)
    unfiltered = record.class.new
    request.query_parameters.fetch(record.model_name.param_key, {}).keys.any? do |field|
      record.try(field).to_s != unfiltered.try(field).to_s
    end
  end

  # Toolbar buttons of the index pages (see application/_index_header).
  # The "new" button is skipped when the user may not create the model or
  # the resource has no new route.
  def new_button(model)
    return unless can?(:new, model) && respond_to?("new_#{model.model_name.singular_route_key}_path")

    link_to icon_text('plus-lg', t_action(:new)), new_polymorphic_path(model), class: 'btn btn-primary'
  end

  def xlsx_button
    link_to icon_text('file-earmark-excel', t_action(:xlsx)), url_for(params.permit!.merge(format: 'xlsx')),
            class: 'btn btn-outline-secondary'
  end

  def boolean_collection
    { 'Ja' => true, 'Nein' => false }
  end

  def term_collection
    site = Site.load
    (site.term_collection_start..site.term_collection_end)
      .reduce([]) { |ar, year| ar << "#{year} Frühling" << "#{year} Herbst" }
  end

  def ects_collection(explicit_mapping: false)
    # ects is an integer enum. since it is used in an sql view
    # we need the explicit db values in some context
    if explicit_mapping
      Mentor.ects.keys.map { |key| [Mentor.humanize_enum('ects', key), Mentor.ects[key]] }
    else
      Mentor.ects.keys.map { |key| [Mentor.humanize_enum('ects', key), key] }
    end
  end

  def exit_reason_collection
    ['Übertritt',
     'Wegzug',
     'Erfolgreich abgeschlossen',
     'Nicht geeignete Massnahme',
     'Andere Gründe']
  end

  def exit_kind_collection
    Kid.exit_kinds.keys.map { |k| [Kid.humanize_enum('exit_kind', k), k] }
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
    collection = if kid
                   [kid.mentor, kid.secondary_mentor].compact
                 else
                   Mentor.active
                 end
    collection.map { |m| [m.display_name, m.id] }
  end

  def teacher_collection(kid = nil)
    collection = if kid
                   [kid.teacher, kid.secondary_teacher, kid.third_teacher].compact
                 else
                   Teacher.active
                 end
    collection.map { |t| [t.display_name, t.id] }
  end

  # values for the collection select 'weekday'
  # weekdays are mapped to integers, as in ruby core's Time, Sunday is 0
  def wday_collection
    (1..5).map { |i| [I18n.t('date.day_names')[i], i] }
  end

  def grade_collection
    (1..6).to_a.reverse
  end

  def goals_reached_collection
    TerminationAssessment.goals_reacheds.keys.map { |k| [TerminationAssessment.humanize_enum('goals_reached', k), k] }
  end

  def kind_collection
    ['bei Familie zu Hause',
     'in der Schule',
     'telefonisch',
     'Mail']
  end

  def reason_collection
    %w[Ersttreffen
       Schulbesuch
       Telefoncoaching
       Weiteres]
  end

  def meeting_time_collection
    min_minutes = Schedule::MIN_HOUR * 60
    max_minutes = (Schedule::LAST_MEETING_HOUR * 60) + Schedule::LAST_MEETING_MIN
    steps = (max_minutes - min_minutes) / 30
    (0..steps).map do |i|
      h, m = (min_minutes + (i * 30)).divmod(60)
      format('%<h>02d:%<m>02d', h: h, m: m)
    end
  end

  def meeting_type_collection
    Journal.meeting_types.keys.map { |s| [Journal.humanize_enum('meeting_type', s), s] }
  end

  def school_kind_collection
    School.school_kinds.keys.map { |s| [School.humanize_enum('school_kind', s), s] }
  end

  def school_district_collection
    School.unscoped.distinct.order(:district).pluck(:district).compact_blank.map { |d| [d, d] }
  end

  # can be used in view to display private data only to their owners (and
  # admins)
  def viewing_own_data?(resource)
    current_user == resource || current_user.is_a?(Admin)
  end

  # determines style class of scheduler cells
  def schedule_class(schedule)
    schedule.last_meeting? ? 'table-info' : ''
  end

  def nav_link(model_name_or_link_text, link_path = nil, icon_name: nil)
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
        link_text = I18n.t(model_name, scope: 'activerecord.models')
      end
      link_path = url_for(controller: model_name.pluralize, action: :index,
                          only_path: true)
    else
      link_text = model_name_or_link_text
    end
    link_text = icon_text(icon_name, link_text) if icon_name
    # active state when link corresponds with current page
    # (first test for request is to make testing easier)
    active = request && current_page?(link_path)
    content_tag(:li, class: 'nav-item') do
      link_to link_text, link_path,
              class: ['nav-link', active ? 'active' : nil].compact.join(' '),
              **(active ? { 'aria-current' => 'page' } : {})
    end
  end

  # The labels of the set boolean fields, one per line -- blank when none is
  # set, so a show_for block around it falls back to its usual blank text.
  def boolean_labels(obj, *fields)
    safe_join(fields.select { |field| obj[field] }.map { |field| tag.div(obj.class.human_attribute_name(field)) })
  end

  def human_date(date)
    return nil if date.blank?

    I18n.l(date)
  end

  # returns the page description translation key of the format
  #
  # page_description.controller.action.user_type
  #
  # user_type is optional
  def page_description
    d = I18n.t("page_description.#{controller_name}.#{action_name}")
    return d[current_user.type.downcase.to_sym] if d.is_a? Hash

    d
  end

  # Returns translated name for the given +model+.
  #
  # If no +model+ is given, it uses the controller name to guess the model by
  # singularize it. +model+ can be both a class or an actual instance.
  #
  # Example:
  #   t_model(Account)     => 'Konto'
  #   t_model(Account.new) => 'Konto'
  #   t_model              => 'Konto' # when called in patients_controller views
  #
  def t_model(model = nil)
    return model.model_name.human if model.is_a? ActiveModel::Naming
    return model.class.model_name.human if model.class.is_a? ActiveModel::Naming
    model_key = if model.is_a? Class
                  model.name.underscore
                elsif model.nil?
                  controller_name.singularize
                else
                  model.class.name.underscore
                end
    I18n.t("activerecord.models.#{model_key}")
  end

  # Page title for the current action: a controller specific
  # "#{controller_name}.#{action_name}.title" translation if there is one,
  # otherwise the generic crud.title one (e.g. "Schüler*in bearbeiten").
  def t_title
    I18n.t("#{controller_name.underscore}.#{action_name}.title",
           default: [:"crud.title.#{action_name}"], model: t_model)
  end

  # Button/link label for +action+ from crud.action, e.g.
  #   t_action(:destroy) => 'Löschen'
  def t_action(action)
    I18n.t("crud.action.#{action}", model: t_model)
  end

  # Returns translated deletion confirmation for +record+.
  #
  # Example:
  #   t_confirm_delete(@school) => 'Schule Hirschengraben wirklich löschen?'
  #
  def t_confirm_delete(record)
    name = record.try(:display_name) || record.try(:title)
    I18n.t('messages.confirm_delete', model: t_model(record), record: name).squish
  end
end
