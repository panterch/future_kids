require 'boot_form_builder'

module BootstrapHelper
    def boot_form_for(object, *args, &block)
    options = args.extract_options!
    simple_form_for(object, *(args << options.merge(builder: BootFormBuilder)), &block)
  end

  def boot_page_title(action_or_title = nil, model = nil)
    if action_or_title.is_a? String
      title = action_or_title
    else
      action = action_or_title || action_name
      if action.to_s == 'show' && defined?(resource) && resource.present?
        title = resource.to_s
      else
        title = t_title(action, model)
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
    content_tag(:i, '', :class => "icon-#{type}")
  end

  # Labels
  # ======
  def boot_label(content, type = nil)
    return "" unless content.present?

    classes = ['label', "label-#{type}"].compact.join(' ')
    content_tag(:span, content, :class => classes)
  end

  # Modal
  # =====
  def modal_header(title)
    content_tag(:div, :class => 'modal-header') do
      content_tag(:button, '&times;'.html_safe, :type => 'button', :class => 'close', 'data-dismiss' => 'modal') +
      content_tag(:h3, title)
    end
  end

  # Messages
  # ========
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

  def boot_alert(*args, &block)
    if block_given?
      type = args[0]
      content = capture(&block)
    else
      content = args[0]
      type    = args[1]
    end

    type ||= 'info'
    content_tag(:div, :class => "alert alert-#{boot_alert_name(type)}") do
      link_to('&times;'.html_safe, '#', :class => 'close', 'data-dismiss' => 'alert') + content
    end
  end

  def boot_no_entry_alert
    boot_alert t('alerts.empty')
  end
end
