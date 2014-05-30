class RenameEtcsToEctsOnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :etcs, :ects
    end
  end
end
