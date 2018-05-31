class AddCommentBccEMailToSite < ActiveRecord::Migration[5.2]
  def change
    add_column :sites, :comment_bcc, :string
  end
end
