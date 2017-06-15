class RenameEtcsToEctsOnUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.rename :etcs, :ects
    end
  end
end
