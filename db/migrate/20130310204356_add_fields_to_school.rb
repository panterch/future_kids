class AddFieldsToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :street, :string
    add_column :schools, :street_no, :string
    add_column :schools, :zip, :string
    add_column :schools, :city, :string
    add_column :schools, :phone, :string
    add_column :schools, :homepage, :string, default: 'http://'
    add_column :schools, :social, :string
    add_column :schools, :district, :string
    add_column :schools, :term, :string
    add_column :schools, :note, :text
  end
end
