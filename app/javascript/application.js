// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import Rails from "@rails/ujs";
import "global";

Rails.start();

// React is only used by the kid/mentor schedules page (see
// show_kid_mentors_schedules.html.haml) -- load it on demand instead of on
// every page. Order matters: react_ujs captures window.React/window.ReactDOM
// once, at load time, so "react" must finish executing (and setting those
// globals) before "react_ujs" runs; and mountComponents() must be called
// explicitly since react_ujs's own DOMContentLoaded listener is registered
// too late to fire for a dynamically-imported module.
if (document.querySelector("[data-react-class]")) {
  import("react")
    .then(() => import("react_ujs"))
    .then(({ default: ReactRailsUJS }) =>
      import("kid_mentor_schedules").then(() => ReactRailsUJS.mountComponents())
    );
}
