class AddFieldsToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :street, :string
    add_column :schools, :street_no, :string
    add_column :schools, :zip, :string
    add_column :schools, :city, :string
    add_column :schools, :phone, :string
    add_column :schools, :homepage, :string
  end
end
