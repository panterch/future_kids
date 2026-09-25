# frozen_string_literal: true

# Nothing in this repo triggers these tasks: each deployment has to schedule
# them itself (hosting platform scheduler or cron, see
# config/crontab.example). See DEPLOYMENT.md.
#
#   schedule:send_journals     daily 05:00 UTC (07:00 Zurich summer time)
#   schedule:create_reminders  daily 22:00 UTC (00:00 Zurich summer time)

namespace :schedule do
  desc 'Run conditionally_create_reminders as schedulable task'
  task create_reminders: :environment do
    Reminder.conditionally_create_reminders
  end

  desc 'Run conditionally_send_journals as schedulable task'
  task send_journals: :environment do
    Teacher.conditionally_send_journals
  end

  desc 'Send a test email to check functionality of cron emails'
  task send_test_email: :environment do
    Notifications.test.deliver_now
  end
end
