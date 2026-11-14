# frozen_string_literal: true

# Suggested values (one per line) for the free text district and subdistrict
# of schools, offered as autocomplete in the school form.
class AddSchoolValueListsToSites < ActiveRecord::Migration[8.1]
  def change
    add_column :sites, :school_districts, :text
    add_column :sites, :school_subdistricts, :text
  end
end
