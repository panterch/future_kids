class AddToThirdTeacherToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :to_third_teacher, :boolean
  end
end
