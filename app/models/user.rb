class User < ApplicationRecord
  include ActionView::Helpers::TextHelper

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one_attached :photo
  validates :photo, content_type: ext_mimes(:jpg, :png, :gif)

  default_scope -> { order(:name, :prename) }
  scope :active, -> { where(inactive: false) }

  before_validation :nilify_blank_password

  validates_presence_of :name, :prename

  has_many :relation_logs, -> { order('created_at DESC') }

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

  protected

  def nilify_blank_password
    if password.blank? && password_confirmation.blank?
      self.password = self.password_confirmation = nil
    end
  end
end
