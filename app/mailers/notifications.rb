class Notifications < ActionMailer::Base
  default :from => "futurekids@panter.ch"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.reminder.subject
  #
  def remind(reminder)
    @reminder = reminder
    mail :to => @reminder.recipient, :cc => "futurekids@panter.ch"
  end
end
