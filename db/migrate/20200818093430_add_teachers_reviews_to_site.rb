class AddTeachersReviewsToSite < ActiveRecord::Migration[6.0]
  def change
    add_column :sites, :teachers_can_access_reviews, :boolean
  end
end
