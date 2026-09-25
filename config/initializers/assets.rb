# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

Rails.application.config.dartsass.builds['print.scss'] = 'print.css'

# Bootstrap 5.3 is written with @import and global Sass functions, which
# Dart Sass deprecates. Hide warnings coming from the gem's own SCSS
# (--quiet-deps) and from @import, which we need to override Bootstrap's
# variables until Bootstrap moves to @use.
Rails.application.config.dartsass.build_options += %w[--quiet-deps --silence-deprecation=import]
