class AddPhoneToKid < ActiveRecord::Migration
  def self.up
    add_column :kids, :phone, :string
  end

  def self.down
    remove_column :kids, :phone
  end
end
