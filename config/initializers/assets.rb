# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.dartsass.builds['print.scss'] = 'print.css'

# react-rails tries to attach its Sprockets-only JSX transform to whatever
# `app.assets` is -- Propshaft also sets `app.assets` (for its own API
# compatibility), so react-rails mistakes it for Sprockets and crashes on
# `Sprockets::VERSION` at boot. Moot anyway: no .jsx files remain, the one
# React component was converted to plain JS (see the plan).
Rails.application.config.react.sprockets_strategy = false
