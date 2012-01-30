class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope :order => [ :name, :prename ]
  scope :active, :conditions => { :inactive => false }
  
  before_validation :nilify_blank_password

  validates_presence_of :name, :prename

  def display_name
    [ name, prename].reject(&:blank?).join(' ')
  end

  def human_absence; absence.try(:textilize); end
  def human_available; available.try(:textilize); end

protected

  def nilify_blank_password
    if password.blank? && password_confirmation.blank?
      self.password = self.password_confirmation = nil
    end
  end

end
