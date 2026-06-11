# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# Sprockets calls CoffeeScriptProcessor.cache_key eagerly (even with no .coffee files),
# which requires the coffee_script gem — not present in production. Stub it out.
module Sprockets
  module CoffeeScriptProcessor
    def self.cache_key
      'CoffeeScriptProcessor:disabled'
    end
  end
end
