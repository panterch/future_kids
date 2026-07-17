# frozen_string_literal: true

class AddJournalSummaryToKids < ActiveRecord::Migration[8.1]
  def change
    add_column :kids, :journal_summary, :text
    add_column :kids, :journal_summary_generated_at, :datetime
  end
end
