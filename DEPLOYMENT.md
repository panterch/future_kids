# Deployment

## Scheduled jobs

Three jobs are part of the business logic. They are **not** triggered
by anything in this repository: each deployment has to schedule them itself,
e.g. with the hosting platform's scheduler or a crontab.

| Rake task | What it does | Suggested time (UTC) | Zurich time |
|---|---|---|---|
| `schedule:send_journals` | Emails each teacher (with `receive_journals`) the journals written in the last 24 hours | 05:00 | 07:00 summer / 06:00 winter |
| `schedule:create_reminders` | Creates missing-journal reminders for mentors and notifies the admins | 22:00 | 00:00 summer / 23:00 winter |
| `schedule:monthly_kid_review` | AI review (summary + signals) of every active kid with a mentor and a new journal since its last review, shown to admins on the kid page. Does nothing unless "KI Nutzung erlauben" is set on the site | 02:00 on the 1st of the month (or daily, see below) | 04:00 summer / 03:00 winter |

The tasks are defined in `lib/tasks/schedule.rake`. `schedule:send_journals`
looks back 24 hours, so it must run exactly once a day; running it twice
sends journals twice, skipping a day loses them.

`schedule:monthly_kid_review` checks itself that it is the 1st of the month
(in Bern time) and does nothing otherwise, so it can also be scheduled daily
by a platform scheduler that has no monthly option, e.g. Heroku Scheduler
daily at 02:00 UTC. A run takes a few hours (about one to two minutes per
kid); a daily Heroku Scheduler job may run up to its interval, so that fits.
Heroku Scheduler doesn't guarantee that a job runs: if a run was missed or
cut off, run it by hand - kids already reviewed are skipped, so running it
again is harmless: `heroku run:detached bin/rails runner
'KidAiReviewer.review_due_kids'` (or `bin/rails runner ...` with cron).

For a host with cron, `config/crontab.example` can be installed as the app
user's crontab.

### Moving to other hosting

1. Recreate all jobs on the new host.
2. Run each task once by hand and check the logs / emails.
3. Only then remove the jobs from the old host, so that no day is skipped
   or run twice.
