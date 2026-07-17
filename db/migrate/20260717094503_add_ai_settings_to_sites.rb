# frozen_string_literal: true

class AddAiSettingsToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :ai_api_url, :string
    add_column :sites, :ai_api_token, :string
    add_column :sites, :ai_model, :string
  end
end
