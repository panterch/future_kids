class AddSimplifiedKidsSchedule < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :kids_schedule_hourly, :boolean, default: true
    add_column :kids, :simplified_schedule, :text
  end
end
