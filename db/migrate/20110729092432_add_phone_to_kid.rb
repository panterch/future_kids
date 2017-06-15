class AddPhoneToKid < ActiveRecord::Migration[4.2]
  def self.up
    add_column :kids, :phone, :string
  end

  def self.down
    remove_column :kids, :phone
  end
end
