# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :timeoutable, :lockable, :validatable

  has_one_attached :photo
  validates :photo, content_type: %i[jpg png gif], size: { less_than: 15.megabytes }

  default_scope -> { order(:name, :prename) }
  scope :active, -> { where(inactive: false) }

  before_validation :nilify_blank_password
  before_save :track_inactive

  validates :name, :prename, presence: true

  has_many :relation_logs, -> { order(created_at: :desc) }, dependent: :nullify, inverse_of: :user

  def display_name
    [name, prename].compact_blank.join(', ')
  end

  enum :exit_kind, { exit: 'exit', later: 'later', continue_term: 'continue_term', continue: 'continue' }
  enum :sex, { male: 'm', female: 'f', diverse: 'd' }

  human_text_attributes :absence, :available, :note, :todo
  human_rails_enum_attributes :exit_kind, :sex

  # drop the upload's EXIF/XMP/IPTC metadata from served variants: phone
  # photos carry GPS coordinates, capture time and device serial numbers,
  # none of which an avatar needs. Keep only the color profile so wide-gamut
  # (e.g. iPhone Display P3) photos don't look washed out; libvips < 8.15
  # can't keep it selectively and strips everything.
  PHOTO_SAVER = Vips.at_least_libvips?(8, 15) ? { keep: 'icc' }.freeze : { strip: true }.freeze

  # whole, uncropped photo for profile pages: ~2x the widest the col-md-4
  # column gets, so it stays sharp on HiDPI screens without shipping the
  # original upload (which can be several MB)
  def photo_medium
    photo.variant(resize_to_limit: [800, 800], saver: PHOTO_SAVER)
  end

  # small square crop for avatars in tables/lists (as opposed to
  # photo_medium's fit-within-bounds, used on profile pages). 2x the 72px
  # an .avatar-sm zooms to on hover
  def photo_thumb
    photo.variant(resize_to_fill: [144, 144], saver: PHOTO_SAVER)
  end

  def self.reset_password!(user)
    new_password = Devise.friendly_token.first(10)
    user.update!(password: new_password, password_confirmation: new_password)
    new_password
  end

  protected

  def nilify_blank_password
    return unless password.blank? && password_confirmation.blank?

    self.password = self.password_confirmation = nil
  end

  def track_inactive
    return unless inactive_changed?

    self.inactive_at = (Time.zone.now if inactive?)
  end
end
