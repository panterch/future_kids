class AddCommentToSubstitutions < ActiveRecord::Migration
  def change
  	add_column :substitutions, :comments, :text
  end
end
