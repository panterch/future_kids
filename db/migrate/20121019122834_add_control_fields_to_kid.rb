class AddControlFieldsToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :checked_at, :date
    add_column :kids, :coached_at, :date
    add_column :kids, :abnormality, :text
    add_column :kids, :abnormality_criticality, :integer
  end
end
