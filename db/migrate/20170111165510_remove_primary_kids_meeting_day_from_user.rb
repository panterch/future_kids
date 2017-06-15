class RemovePrimaryKidsMeetingDayFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :primary_kids_meeting_day, :interger
  end
end
