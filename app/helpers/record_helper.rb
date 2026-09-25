# frozen_string_literal: true

# Building blocks of the record pages (show/edit/new), which put their
# actions into the layout's sidebar (content_for :sidebar) -- see
# layouts/application.html.haml and application/_record_header. The
# sidebar is a .d-grid, so these buttons need no width/spacing classes and
# work unchanged in the compact mobile header.
module RecordHelper
  # The record of the current controller, e.g. @mentor in MentorsController.
  def page_record
    instance_variable_get("@#{controller_name.singularize}")
  end

  # Page <h1>, also stored as content_for(:page_title) (the mobile sidebar's
  # offcanvas title). Without an explicit title, show pages use the record's
  # name and every other action its crud.title translation.
  def page_title(title = nil)
    title ||= if action_name == 'show' && (record = page_record)
                record.try(:display_name) || record.to_s
              else
                t_title
              end
    content_for :page_title, title
    tag.h1(title)
  end

  def edit_button
    record_button(:edit, 'pencil', 'btn btn-primary')
  end

  def show_button
    record_button(:show, 'eye', 'btn btn-outline-secondary')
  end

  def delete_button
    record_button(:destroy, 'trash', 'btn btn-outline-danger') do
      { method: :delete, data: { confirm: t_confirm_delete(page_record) } }
    end
  end

  # Submits the record page's form from the sidebar, found by the id
  # form_for gives it (e.g. "edit_kid_12"). The mobile header passes a short
  # label, since the full one ("<Model> aktualisieren") doesn't fit next to
  # the title on a phone.
  def submit_button(label: nil)
    label ||= t("helpers.submit.#{page_record.persisted? ? :update : :create}", model: t_model)
    form_id = dom_id(page_record, page_record.persisted? ? :edit : :new)
    button_tag icon_text('check-lg', label), type: 'submit', form: form_id, class: 'btn btn-primary'
  end

  # Path of another action of the current record, nil when the controller
  # has no such route (e.g. comments cannot be destroyed, the site settings
  # have no index). Memoized: the sidebar and the mobile header ask for the
  # same actions, and a missing route is only detectable by url_for raising.
  def action_path(action)
    @action_paths ||= {}
    return @action_paths[action] if @action_paths.key?(action)

    @action_paths[action] = begin
      url_for(action: action)
    rescue ActionController::UrlGenerationError
      nil
    end
  end

  private

  # The block, if given, returns extra link_to options -- only evaluated when
  # the button is actually rendered.
  def record_button(action, icon_name, css_class)
    return unless can?(action, page_record) && (path = action_path(action))

    link_to icon_text(icon_name, t_action(action)), path, class: css_class, **(block_given? ? yield : {})
  end
end
