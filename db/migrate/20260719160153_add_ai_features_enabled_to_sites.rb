# frozen_string_literal: true

class AddAiFeaturesEnabledToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :ai_features_enabled, :boolean, default: false, null: false
  end
end
