class AddToThirdTeacherToComment < ActiveRecord::Migration
  def change
    add_column :comments, :to_third_teacher, :boolean
  end
end
