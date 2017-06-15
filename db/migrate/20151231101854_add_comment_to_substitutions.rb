class AddCommentToSubstitutions < ActiveRecord::Migration[4.2]
  def change
  	add_column :substitutions, :comments, :text
  end
end
