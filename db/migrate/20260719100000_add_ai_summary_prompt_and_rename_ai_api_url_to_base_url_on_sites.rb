# frozen_string_literal: true

class AddAiSummaryPromptAndRenameAiApiUrlToBaseUrlOnSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :ai_summary_prompt, :text
    rename_column :sites, :ai_api_url, :ai_api_base_url
  end
end
