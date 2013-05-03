class Notifications < ActionMailer::Base
  default :from => "AOZ Future Kids <info@aoz-futurekids.ch>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.reminder.subject
  #
  def remind(reminder)
    @reminder = reminder
    mail :to => @reminder.recipient, :bcc => "info@aoz-futurekids.ch"
  end

  def reminders_created(count)
    @count = count
    mail :to => "info@aoz-futurekids.ch"
  end

  def comment_created(comment)
    @comment = comment
    @journal = comment.journal
    @kid = @journal.kid
    cc = []
    cc << @kid.admin.email if @kid.admin
    to = @journal.mentor.email
    mail :to => to, :cc => cc
  end

  def test(to)
    mail :subject => 'future kids test mail', :to => to
  end

end
