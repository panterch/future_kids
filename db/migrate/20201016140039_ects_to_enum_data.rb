class EctsToEnumData < ActiveRecord::Migration[6.0]

  def up
    Mentor.where("ects_legacy=true").update_all(ects: :currently)
  end

end
