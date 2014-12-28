class Notifications < ActionMailer::Base
  default :from => "AOZ Future Kids <futurekids@aoz.ch>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.reminder.subject
  #
  def remind(reminder)
    @reminder = reminder
    mail :to => @reminder.recipient, :bcc => "futurekids@aoz.ch"
  end

  def reminders_created(count)
    @count = count
    mail :to => "futurekids@aoz.ch"
  end

  def comment_created(comment)
    @comment = comment
    @journal = comment.journal
    @kid = @journal.kid
    mail :to => @comment.recipients
  end

  def test(to)
    mail :subject => 'future kids test mail', :to => to
  end

  def journals_created(to, journals)
    @journals = journals
    mail to: to.email
  end

end
