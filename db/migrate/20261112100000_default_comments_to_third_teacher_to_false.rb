# frozen_string_literal: true

# to_teacher and to_secondary_teacher default to false, to_third_teacher was
# added without a default and holds NULL for comments written since
class DefaultCommentsToThirdTeacherToFalse < ActiveRecord::Migration[8.1]
  def up
    execute 'UPDATE comments SET to_third_teacher = false WHERE to_third_teacher IS NULL'
    change_column_default :comments, :to_third_teacher, from: nil, to: false
    change_column_null :comments, :to_third_teacher, false
  end

  def down
    change_column_null :comments, :to_third_teacher, true
    change_column_default :comments, :to_third_teacher, from: false, to: nil
  end
end
