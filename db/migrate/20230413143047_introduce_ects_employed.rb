class IntroduceEctsEmployed < ActiveRecord::Migration[6.1]
  def up
    Mentor.where(ects: nil).update_all(ects: :employed)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
