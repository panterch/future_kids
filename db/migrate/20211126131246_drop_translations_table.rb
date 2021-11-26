class DropTranslationsTable < ActiveRecord::Migration[6.1]

  def up
    drop_table :translations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
