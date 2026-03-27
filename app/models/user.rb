class User < ApplicationRecord
  include HasCoordinates
  include ActionView::Helpers::TextHelper

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one_attached :photo
  validates :photo, content_type: %i[jpg png gif], size: { less_than: 15.megabytes }

  default_scope -> { order(:name, :prename) }
  scope :active, -> { where(inactive: false) }

  before_validation :nilify_blank_password
  before_save :track_inactive

  validates :name, :prename, presence: true

  has_many :relation_logs, -> { order('created_at DESC') }, dependent: :nullify

  def display_name
    [name, prename].reject(&:blank?).join(', ')
  end

  def terms_of_use_accepted
    terms_of_use_accepted_at > Site.load.terms_of_use_content_changed_at
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
    { 'm' => 'männlich', 'f' => 'weiblich', 'd' => 'divers' }[sex]
  end

  def photo_medium
    photo.variant(resize_to_fit: [300, 300])
  end

  def self.reset_password!(user)
    @new_password = Devise.friendly_token.first(10)
    user.update!(password: @new_password, password_confirmation: @new_password)
    @new_password
  end

  protected

  def nilify_blank_password
    return unless password.blank? && password_confirmation.blank?

    self.password = self.password_confirmation = nil
  end

  def track_inactive
    return unless inactive_changed?

    self.inactive_at = (Time.now if inactive?)
  end

  # on instances with public signup configured stronger validations are applied
  def validate_public_signup_fields?
    Site.load.public_signups_active?
  end
end
