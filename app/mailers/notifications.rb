class Notifications < ActionMailer::Base
  default :from => "AOZ Future Kids <futurekids@panter.ch>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.reminder.subject
  #
  def remind(reminder)
    @reminder = reminder
    mail :to => @reminder.recipient, :bcc => "futurekids@panter.ch"
  end

  def reminders_created(count)
    @count = count
    mail :to => "futurekids@panter.ch"
  end

  def test(to)
    mail :subject => 'future kids test mail', :to => to
  end

end
