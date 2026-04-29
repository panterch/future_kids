class Notifications < ActionMailer::Base
  def self.default_email
    email = Site.first_or_create.try(:notifications_default_email)
    email = I18n.t('notifications.default_email') if email.blank?
    email
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

  # sends out a simple test email
  # Notifications.test('futurekids@example.com').deliver_later
  def test(to = ENV.fetch('TEST_EMAIL_TO', nil))
    Rails.logger.info "Sending test email from #{Notifications.default_email} to #{to}"
    mail subject: 'future kids test mail', to: to
  end
end
