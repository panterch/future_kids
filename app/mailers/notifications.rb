class Notifications < ActionMailer::Base

  def self.default_email
    email = Site.first_or_create.try(:notifications_default_email)
    if email.blank?
      email = I18n.t('notifications.default_email')
    end
    return email
  end


  default from: Notifications.default_email


  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.reminder.subject
  #
  def remind(reminder)
    @reminder = reminder
    mail to: @reminder.recipient, bcc: Site.load.comment_bcc
  end

  def reminders_created(count)
    @count = count
    mail to: Notifications.default_email
  end

  def comment_created(comment)
    @site = Site.load
    @comment = comment
    @journal = comment.journal
    @kid = @journal.kid
    mail to: @comment.recipients, bcc: @site.comment_bcc
  end

  def journals_created(to, journals)
    @journals = journals
    mail to: to.email
  end

  def important_journal_created(journal)
    @journal = journal
    recipients = []
    recipients << Notifications.default_email
    recipients << @journal.kid.admin&.email if @journal.kid.admin
    mail subject: I18n.t('notifications.important_subject'),
         to: recipients
  end

  def first_year_assessment_created(assessment)
    @assessment = assessment
    mail to: Notifications.default_email
  end

  def termination_assessment_created(assessment)
    @assessment = assessment
    mail to: Notifications.default_email
  end

  def mentor_matching_created(mentor_matching)
    @mentor_matching = mentor_matching
    mail to: mentor_matching.kid.teacher.email if mentor_matching.kid.teacher
  end

  def mentor_matching_reserved(mentor_matching)
    @mentor_matching = mentor_matching
    mail to: mentor_matching.mentor.email
  end

  def mentor_matching_declined(mentor_matching)
    @mentor_matching = mentor_matching
    mail to: mentor_matching.mentor.email
  end

  def mentor_matching_declined_by_mentor(mentor_matching)
    @mentor_matching = mentor_matching
    mail to: mentor_matching.kid.teacher.email if mentor_matching.kid.teacher
  end

  def mentor_matching_confirmed(mentor_matching)
    @mentor_matching = mentor_matching
    recipients = []
    recipients << mentor_matching.kid.teacher&.email if mentor_matching.kid.teacher
    mail to: recipients, bcc: Notifications.default_email
  end

  def mentor_no_kids_reminder(mentor)
    @mentor = mentor
    mail to: mentor.email
  end

  def user_registered(user)
    @user = user
    @user_type = @user.class.model_name.human
    @user_link = @user.is_a?(Teacher) ? edit_teacher_url(@user) : edit_mentor_url(@user.id)
    mail(to: Notifications.default_email,
         subject: I18n.t('notifications.user_registered.subject', user_type: @user_type))
  end

  def reset_and_send_mentor_password(user)
    @user = user
    @new_password = User.reset_password!(@user)
    mail(to: @user.email, subject: I18n.t('notifications.reset_and_send_password.subject', password: @new_password))
  end

  def reset_and_send_teacher_password(user)
    @user = user
    @new_password = User.reset_password!(@user)
    mail(to: @user.email, subject: I18n.t('notifications.reset_and_send_password.subject', password: @new_password))
  end

  # sends out a simple test email
  # Notifications.test('futurekids@example.com').deliver_later
  def test(to)
    mail subject: 'future kids test mail', to: to
  end


end
