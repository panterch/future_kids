class SelfRegistrationsMailer < ActionMailer::Base

  def self.default_email
    email = Site.first_or_create.try(:notifications_default_email)
    if email.blank?
      email = I18n.t('notifications.default_email')
    end
    return email
  end

  default from: SelfRegistrationsMailer.default_email

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.self_registrations.reminder.subject
  #
  def user_registered(user)
    @user = user
    @user_type = @user.type
    @user_link = @user_type == 'Teacher' ? edit_teacher_url(@user) : edit_mentor_url(@user.id)
    mail(to: Admin.all.collect(&:email).join(','),
         subject: I18n.t('self_registrations_mailer.user_registered.subject', user_type: @user_type))
  end

  def reset_and_send_password(user)
    @user = user
    @new_password = Devise.friendly_token.first(10)
    @user.update(password: @new_password, password_confirmation: @new_password)
    mail(to: @user.email, subject: I18n.t('self_registrations_mailer.reset_and_send_password.subject', password: @new_password))
  end
end
