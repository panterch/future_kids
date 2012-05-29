class Notifications < ActionMailer::Base
  default :from => "futurekids@aoz.ch"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.reminder.subject
  #
  def remind(reminder)
    @reminder = reminder
    mail :to => @reminder.recipient, :cc => "futurekids@aoz.ch"
  end

  def reminders_created(count)
    @count = count
    mail :to => "futurekids@aoz.ch"
  end
end
