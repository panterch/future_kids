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

  def kid_collection
    collection = Kid.active
    collection.map { |k| [k.display_name, k.id] }
  end

  def order_by_collection_for_kids(selected)
    options = [%w[Name name],
               %w[Kontrolldatum checked_at],
               %w[Coachingdatum coached_at],
               %w[Erfassungsdatum created_at]]
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

  def duration_collection
    [
      ['30 Minuten', 30],
      ['1 Stunde', 60],
      ['1½ Stunden', 90],
      ['2 Stunden', 120]
    ]
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
    link_text = icon(icon_name) + ' ' + link_text if icon_name
    # active state when link corresponds with current page
    # (first test for request is to make testing easier)
    active = request && current_page?(link_path)
    content_tag(:li, class: 'nav-item') do
      link_to link_text, link_path,
              class: ['nav-link', active ? 'active' : nil].compact.join(' '),
              **(active ? { 'aria-current' => 'page' } : {})
    end
  end

  # renders a title inside the form, aligned with form fields
  def form_subtitle(text)
    tag.p tag.strong text
  end

  # renders the label of a boolean field when it is set fitting into
  # a show_for context
  def conditionally_show_for(obj, field)
    return unless obj[field]

    tag.div(I18n.t("activerecord.attributes.#{obj.model_name.to_s.downcase}.#{field}"))
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

  # Returns translated name for the given +attribute+.
  #
  # If no +model+ is given, it uses the controller name to guess the model by
  # singularize it.
  #
  # Example:
  #   t_attr('first_name', Patient) => 'Vorname'
  #   t_attr('first_name')          => 'Vorname' # when called in patients_controller views
  #
  def t_attr(attribute, model = nil)
    model ||= controller_name.classify.constantize
    model.human_attribute_name(attribute)
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

  # Returns translated title for current +action+ on +model+.
  #
  # If no +action+ is given, it uses the current action.
  #
  # If no +model+ is given, it uses the controller name to guess the model by
  # singularize it. +model+ can be both a class or an actual instance.
  #
  # The translation file comming with the plugin supports the following actions
  # by default: index, edit, show, new, delete
  #
  # You may provide controller specific titles in the translation file. The keys
  # should have the following format:
  #
  #   #{controller_name}.#{action}.title
  #
  # Example:
  #   t_title('new', Account) => 'Konto anlegen'
  #   t_title('delete')       => 'Konto löschen' # when called in accounts_controller views
  #   t_title                 => 'Konto ändern'  # when called in accounts_controller edit view
  #
  def t_title(action = nil, model = nil)
    model_key = model&.model_name&.i18n_key || model&.class&.model_name&.i18n_key ||
      controller_name.underscore
    I18n.t("#{model_key}.#{action || action_name}.title",
      default: [:"crud.title.#{action || action_name}"], model: t_model(model))
  end
  alias :t_crud :t_title

  # Returns translated string for current +action+.
  #
  # If no +action+ is given, it uses the current action.
  #
  # The translation file comes with the plugin supports the following actions
  # by default: index, edit, show, new, delete, back, next, previous
  #
  # Example:
  #   t_action('delete')        => 'Löschen'
  #   t_action                  => 'Ändern'  # when called in an edit view
  #
  def t_action(action = nil, model = nil)
    I18n.t("crud.action.#{action || action_name}", model: t_model(model))
  end

  # Returns translated deletion confirmation for +record+.
  #
  # It uses +record+.to_s in the message.
  #
  # Example:
  #   t_confirm_delete(@account) => 'Konto Kasse wirklich löschen'
  #
  def t_confirm_delete(record)
    I18n.t('messages.confirm_delete', model: t_model(record), record: record.to_s)
  end

  # Returns translated drop down field prompt for +model+.
  #
  # If no +model+ is given, it tries to guess it from the controller.
  #
  # Example:
  #   t_select_prompt(Account) => 'Konto auswählen'
  #
  def t_select_prompt(model = nil)
    I18n.t('messages.select_prompt', model: t_model(model))
  end

  # Returns translated identifier
  def t_page_head
    if params[:id] && defined?(resource) && resource
      "#{t_title} #{resource}"
    else
      t_title
    end
  end

  # CRUD helpers
  def action_to_icon(action)
    case action.to_s
    when 'new'
      "plus-lg"
    when 'show'
      "eye"
    when 'edit'
      "pencil"
    when 'delete', 'destroy'
      "trash"
    when "index", "list"
      "card-list"
    when "update"
      "arrow-clockwise"
    when "copy"
      "copy"
    else
      action
    end
  end

  def icon_link_to(action, url = nil, options = {})
    classes = []
    if class_options = options.delete(:class)
      classes << class_options.split(' ')
    end

    classes << 'list-group-item'

    if action.is_a? Symbol
      url ||= {:action => action}
      title = t_action(action)
    else
      title = action
    end

    icon = options.delete(:icon)
    icon ||= action

    type = options.delete(:type)
    classes << "btn-#{type}" unless type.blank?

    options.merge!(:class => classes.join(" "))
    link_to(url_for(url), options) do
      boot_icon(action_to_icon(icon)) + " " + title
    end
  end

  def contextual_link_to(action, resource_or_model = nil, link_options = {})
    # We don't want to change the passed in link_options
    options = link_options.dup

    # Handle both symbols and strings
    action = action.to_sym

    # Resource and Model setup
    # Use controller name to guess resource or model if not specified
    case action
    when :new, :index
      default_model = controller_name.singularize.camelize.constantize
      model = resource_or_model || default_model
      explicit_resource_or_model = default_model != model
    when :show, :edit, :delete, :destroy
      default_resource = instance_variable_get("@#{controller_name.singularize}")
      resource = resource_or_model || default_resource
      model = resource.class
      explicit_resource_or_model = default_resource != resource
    else
      default_model = controller_name.singularize.camelize.constantize
      model = resource_or_model || default_model
      explicit_resource_or_model = default_model != model
    end
    model_name = model.to_s.underscore

    unless resource_or_model.is_a?(String)
      # No link if CanCan is used and current user isn't authorized to call this action
      return if respond_to?(:cannot?) and cannot?(action.to_sym, model)
    end

    # Option generation
    case action
    when :delete, :destroy
      options.merge!(:data => { :confirm => t_confirm_delete(resource) }, :method => :delete)
    end

    begin
      if resource_or_model.is_a?(String)
        path = resource_or_model
      else
        # Path generation
        case action
        when :index
          if explicit_resource_or_model
            path = polymorphic_path(model)
          else
            path = url_for(:action => nil)
          end
        when :delete, :destroy
          if explicit_resource_or_model
            path = polymorphic_path(resource)
          else
            path = url_for(:action => :destroy)
          end
        else
          if explicit_resource_or_model
            # polymorphic_path has no "show_kid_path" route to look up -- :show
            # is its implicit default action, so only pass :action for others.
            path = if action == :show
                     polymorphic_path(resource_or_model)
                   else
                     polymorphic_path(resource_or_model, :action => action)
                   end
          else
            path = url_for(:action => action)
          end
        end
      end

      return icon_link_to(action, path, options)

    rescue ActionController::UrlGenerationError
      # This handles cases where we did exclude crud actions in the routing map.
    end
  end

  def contextual_links_for(action = nil, resource_or_model = nil, options = {})
    # Use current action if not specified
    action ||= action_name

    # Handle both symbols and strings
    action = action.to_sym

    actions = []
    case action
    when :new, :create
      actions << :index
    when :show
      actions += [:edit, :destroy, :index]
    when :edit, :update
      actions += [:show, :destroy, :index]
    when :index
      actions << :new
    end

    links = actions.map{|link_for| contextual_link_to(link_for, resource_or_model, options)}

    return links.join("\n").html_safe
  end

  def contextual_links(action = nil, resource_or_model = nil, options = {}, &block)
    content_tag('div', :class => 'list-group') do
      content = contextual_links_for(action, resource_or_model, options)
      if block_given?
        additional_content = capture(&block)
        content += ("\n" + additional_content).html_safe unless additional_content.nil?
      end
      content
    end
  end
end
