# frozen_string_literal: true

module AvatarsHelper
  # renders a circular avatar for a User (Mentor/Teacher/Admin/Principal) or
  # Kid: their uploaded photo if present, otherwise initials on a color
  # keyed to their type (see avatar_type). size is :sm, :md, or :lg.
  def avatar(resource, size: :md)
    return '' if resource.blank?

    has_photo = resource.respond_to?(:photo) && resource.photo.present?
    classes = ['avatar', "avatar-#{size}", "avatar-#{avatar_type(resource)}"]
    # the hover-zoom (see .avatar-photo in application.scss) only makes sense
    # over an actual picture -- zooming a two-letter initials blob doesn't
    # reveal anything new, so it's scoped to this modifier class.
    classes << 'avatar-photo' if has_photo

    content_tag(:span, class: classes.join(' ')) do
      if has_photo
        # profile pages (:lg) show the avatar much bigger than the 96px
        # photo_thumb variant has resolution for, so use the original
        # upload there instead -- it's cropped to a circle by CSS anyway,
        # and this is a single image per page rather than a whole table/
        # list of them, so the bigger download is cheap.
        src = size == :lg ? rails_blob_path(resource.photo) : rails_representation_url(resource.photo_thumb)
        image_tag src, class: 'avatar-img', alt: resource.display_name
      else
        content_tag(:span, avatar_initials(resource), class: 'avatar-initials', 'aria-hidden': true)
      end
    end
  end

  # the full, uncropped photo for a user's own profile page (mentors/admins/
  # teachers/principals show pages) -- staff use this to actually recognize
  # the person, so unlike the circular, cover-cropped :lg avatar it must show
  # the whole uploaded image. Falls back to the regular :lg avatar (initials)
  # when there's no photo, or for a resource that can't have one (Kid).
  def profile_photo(resource)
    return '' if resource.blank?
    return content_tag(:div, avatar(resource, size: :lg), class: 'mb-4') unless resource.respond_to?(:photo) && resource.photo.present?

    content_tag(:div, class: 'profile-portrait mb-4') do
      image_tag rails_blob_path(resource.photo), class: 'profile-portrait-img', alt: resource.display_name
    end
  end

  # avatar + can_link_to's linked (or plain) display name, side by side --
  # for table rows and lists. Keeps can_link_to itself untouched since it's
  # also used in dense show_for attribute rows where an avatar per row would
  # be noise rather than signal.
  def avatar_link_to(resource, size: :md)
    return '' if resource.blank?

    content_tag(:span, class: 'avatar-link d-inline-flex align-items-center gap-2') do
      avatar(resource, size: size) + can_link_to(resource)
    end
  end

  private

  def avatar_type(resource)
    case resource
    when Mentor then 'mentor'
    when Teacher then 'teacher'
    when Admin then 'admin'
    when Principal then 'principal'
    when Kid then 'kid'
    else 'default'
    end
  end

  def avatar_initials(resource)
    parts = [resource.try(:prename), resource.try(:name)].compact_blank
    return '?' if parts.empty?
    return parts.first[0, 2].upcase if parts.size == 1

    parts.map { |part| part[0] }.join.upcase
  end
end
