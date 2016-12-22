class AddThirdTeacherToKid < ActiveRecord::Migration
  def change
    add_column :kids, :third_teacher_id, :integer
  end
end
