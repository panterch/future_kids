# frozen_string_literal: true

module BootstrapHelper
  if defined?(SimpleForm)
    def boot_form_for(object, *args, &block)
      options = args.extract_options!
      simple_form_for(object, *(args << options.merge(builder: BootFormBuilder)), &block)
    end
  end

  def boot_page_title(action_or_title = nil, model = nil, &block)
    if block_given?
      title = capture(&block)
    else
      if action_or_title.is_a? String
        title = action_or_title
      else
        action = action_or_title || action_name
        if action.to_s == 'show' && defined?(resource) && resource.present?
          title = resource.display_name if resource.respond_to?(:display_name)
          title ||= resource.to_s
        else
          title = t_title(action, model)
        end
      end
    end

    content_for :page_title, title
    content_tag(:div, :class => 'page-header') do
      content_tag(:h1, title)
    end
  end

  # Icons
  # =====
  def boot_icon(type)
    icon(type.to_s)
  end

  # Labels
  # ======
  def boot_label(content, type = nil)
    return "" unless content.present?

    classes = ['label', "label-#{type}"].compact.join(' ')
    content_tag(:span, content, :class => classes)
  end

  # Messages
  # ========
  # Map common rails flash types to bootstrap alert names.
  def boot_alert_name(type)
    case type
    when 'alert'
      'danger'
    when 'notice'
      'info'
    else
      type
    end
  end

  def boot_alert_icon(type)
    case boot_alert_name(type)
    when 'danger', 'warning'
      'exclamation-triangle'
    when 'success'
      'check-circle'
    else
      'info-circle'
    end
  end

  def boot_alert(*args, icon_name: nil, &block)
    if block_given?
      type = args[0]
      content = capture(&block)
    else
      content = args[0]
      type    = args[1]
    end

    type ||= 'info'
    content_tag(:div, :class => "alert alert-#{boot_alert_name(type)} alert-dismissible") do
      content_tag(:button, '', :type => 'button', :class => 'btn-close', 'data-bs-dismiss' => 'alert', 'aria-label' => 'Close') +
        icon(icon_name || boot_alert_icon(type)) + ' ' + content
    end
  end

  def boot_no_entry_alert
    boot_alert t('alerts.empty'), icon_name: 'inbox'
  end

end
