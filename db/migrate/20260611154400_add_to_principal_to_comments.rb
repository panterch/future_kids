# frozen_string_literal: true

class AddToPrincipalToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :to_principal, :boolean, default: false, null: false
  end
end
