class User < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :photo,
    :styles => { :medium => [ "300x300>", :png] },
    :default_url => "/images/:style/missing.png",
    path: ":rails_root/public/system/:attachment/:id/:style/:filename",
    url: "/system/:attachment/:id/:style/:filename"

  validates_attachment_content_type :photo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  default_scope -> { order(:name, :prename) }
  scope :active, -> { where(:inactive => false) }

  before_validation :nilify_blank_password

  validates_presence_of :name, :prename

  has_many :relation_logs, -> { order('created_at DESC') }

  def display_name
    [ name, prename].reject(&:blank?).join(' ')
  end

  def human_absence;   simple_format(absence); end
  def human_available; simple_format(available); end
  def human_todo;      simple_format(todo); end

protected

  def nilify_blank_password
    if password.blank? && password_confirmation.blank?
      self.password = self.password_confirmation = nil
    end
  end

end
