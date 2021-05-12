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
end
