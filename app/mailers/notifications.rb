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

  def test(to)
    mail subject: 'future kids test mail', to: to
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
    recipients << Notifications.default_email
    recipients << mentor_matching.kid.admin&.email if mentor_matching.kid.admin
    mail to: recipients
  end
end
