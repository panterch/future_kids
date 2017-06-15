class AddThirdTeacherToKid < ActiveRecord::Migration[4.2]
  def change
    add_column :kids, :third_teacher_id, :integer
  end
end
