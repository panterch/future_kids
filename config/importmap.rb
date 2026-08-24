# Pin npm packages by running ./bin/importmap

pin "application"
pin "global"
pin "treeview"
pin "icons"

# actionview's own rails-ujs.esm.js -- a genuine ES module, no UMD patching
# needed (unlike the react-* files below). Named rails_ujs_esm.js, not
# rails-ujs.js: actionview also ships a classic-script rails-ujs.js on
# Sprockets' own load path (still active pre-Phase-4), and that logical
# filename would collide and win over ours.
pin '@rails/ujs', to: 'rails_ujs_esm.js'

# Only used by the kid/mentor schedules page (show_kid_mentors_schedules.html.haml).
# preload: false keeps these off every other page's modulepreload tags --
# application.js dynamic-imports them on demand instead.
#
# react/react_ujs/classnames/react-input-autosize/react-select are vendored
# by hand from the react-rails gem / vendor/assets/javascripts, not npm. Each
# file has a small patch appended/applied on top of the unmodified library
# code to make it a real ES module (see git history for the exact diff) --
# see the plan for why: importmap-rails does no bundling/transformation, so
# these need to be loadable as native ES modules as-is.
pin "kid_mentor_schedules", preload: false
pin "htm", preload: false # @3.1.1
pin "react", to: Rails.env.production? ? 'react.production.js' : 'react.development.js', preload: false
pin 'react_ujs', preload: false
pin 'classnames', preload: false
pin 'react-input-autosize', preload: false
pin 'react-select', preload: false
