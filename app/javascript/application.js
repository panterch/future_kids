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
//
// We read window.ReactRailsUJS directly rather than react_ujs's own default
// export: that export is `export default window.ReactRailsUJS` appended to
// the vendored UMD bundle, a one-time snapshot taken while the bundle's own
// factory is still running -- it can freeze on the pre-assignment
// `undefined` even though the global itself ends up set correctly.
if (document.querySelector("[data-react-class]")) {
  const reactReady = import("react");
  const componentReady = reactReady.then(() => import("kid_mentor_schedules"));

  reactReady
    .then(() => import("react_ujs"))
    .then(() => componentReady.then(() => window.ReactRailsUJS.mountComponents()))
    .catch((error) => console.error("[kid_mentor_schedules] failed to load/mount:", error));
}
