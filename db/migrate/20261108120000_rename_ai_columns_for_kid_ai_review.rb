# frozen_string_literal: true

# JournalSummarizer and KidSignalDetector were merged into KidAiReviewer: one
# monthly AI call per kid, its whole markdown answer (summary and signals) is
# stored as is
class RenameAiColumnsForKidAiReview < ActiveRecord::Migration[8.1]
  def change
    change_table :kids, bulk: true do |t|
      t.rename :journal_summary, :ai_review
      t.rename :journal_summary_generated_at, :ai_review_generated_at
    end

    # the prompt is part of the code now (KidAiReviewer::INSTRUCTIONS), tightly
    # coupled to the profile and the answer format
    remove_column :sites, :ai_summary_prompt, :text
  end
end
