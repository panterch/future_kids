class User < ApplicationRecord
  include ActionView::Helpers::TextHelper, HasCoordinates

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one_attached :photo
  validates :photo, content_type: [:jpg, :png, :gif], size: { less_than: 15.megabytes }

  default_scope -> { order(:name, :prename) }
  scope :active, -> { where(inactive: false) }

  before_validation :nilify_blank_password
  before_save :track_inactive

  validates_presence_of :name, :prename

  has_many :relation_logs, -> { order('created_at DESC') }, dependent: :nullify

  enum state: { selfservice: 'selfservice',
                queued: 'queued',
                invited: 'invited',
                accepted: 'accepted',
                declined: 'declined' }

  def display_name
    [name, prename].reject(&:blank?).join(' ')
  end

  def human_absence
    text_format(absence)
  end

  def human_available
    text_format(available)
  end

  def human_todo
    text_format(todo)
  end

  def human_sex
    { 'm' => '♂', 'f' => '♀' }[sex]
  end

  def photo_medium
    photo.variant(resize: '300x300>').processed
  end

  def human_state
    I18n.t("activerecord.attributes.user.states.#{state}")
  end

  def self.human_state(state)
    I18n.t("activerecord.attributes.user.states.#{state}")
  end

  protected

  def nilify_blank_password
    if password.blank? && password_confirmation.blank?
      self.password = self.password_confirmation = nil
    end
  end

  def track_inactive
    return unless inactive_changed?
    if inactive?
      self.inactive_at = Time.now
    else
      self.inactive_at = nil
    end
  end
end
