# frozen_string_literal: true

# A subdivision of a school's district (e.g. the Schulkreise of a city), free
# text like the district. Optional: schools outside such a subdivision leave it empty.
class AddSubdistrictToSchools < ActiveRecord::Migration[8.1]
  def change
    add_column :schools, :subdistrict, :string
  end
end
