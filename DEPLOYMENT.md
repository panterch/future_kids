# Deployment

## Scheduled jobs

Two daily jobs are part of the business logic. They are **not** triggered
by anything in this repository: each deployment has to schedule them itself,
e.g. with the hosting platform's scheduler or a crontab.

| Rake task | What it does | Suggested time (UTC) | Zurich time |
|---|---|---|---|
| `schedule:send_journals` | Emails each teacher (with `receive_journals`) the journals written in the last 24 hours | 05:00 | 07:00 summer / 06:00 winter |
| `schedule:create_reminders` | Creates missing-journal reminders for mentors and notifies the admins | 22:00 | 00:00 summer / 23:00 winter |

The tasks are defined in `lib/tasks/schedule.rake`. `schedule:send_journals`
looks back 24 hours, so it must run exactly once a day; running it twice
sends journals twice, skipping a day loses them.

`rake schedule:send_test_email` sends a test email to check mail delivery
from the scheduler.

For a host with cron, `config/crontab.example` can be installed as the app
user's crontab.

### Moving to other hosting

1. Recreate both jobs on the new host.
2. Run each task once by hand and check the logs / emails.
3. Only then remove the jobs from the old host, so that no day is skipped
   or run twice.
