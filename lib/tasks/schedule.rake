# frozen_string_literal: true

# Nothing in this repo triggers these tasks: each deployment has to schedule
# them itself (hosting platform scheduler or cron, see
# config/crontab.example). See DEPLOYMENT.md.
#
#   schedule:send_journals     daily 05:00 UTC (07:00 Zurich summer time)
#   schedule:create_reminders  daily 22:00 UTC (00:00 Zurich summer time)
#   schedule:monthly_kid_review  daily 02:00 UTC, does something only on
#                                the 1st of the month

namespace :schedule do
  desc 'Run conditionally_create_reminders as schedulable task'
  task create_reminders: :environment do
    Reminder.conditionally_create_reminders
  end

  desc 'Run conditionally_send_journals as schedulable task'
  task send_journals: :environment do
    Teacher.conditionally_send_journals
  end

  # checks the 1st of the month itself (in the app's Bern time zone), so a
  # scheduler that can only run daily (Heroku Scheduler) works too. To run it
  # on another day: bin/rails runner 'KidAiReviewer.review_due_kids'
  desc 'AI review (summary + signals) of kids with new journals, only on the 1st of the month'
  task monthly_kid_review: :environment do
    KidAiReviewer.review_due_kids if Date.current.day == 1
  end
end
