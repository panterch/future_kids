// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Rails from "@rails/ujs";
import "global";

Rails.start();

// React is only used by the kid/mentor schedules page (see
// show_kid_mentors_schedules.html.haml) -- load it on demand instead of on
// every page.
const kidMentorSchedules = document.getElementById("kid-mentor-schedules");
if (kidMentorSchedules) {
  import("kid_mentor_schedules")
    .then(({ mount }) => mount(kidMentorSchedules))
    .catch((error) => console.error("[kid_mentor_schedules] failed to load/mount:", error));
}
