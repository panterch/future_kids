class CreateKidMentorRelations < ActiveRecord::Migration
  def up
    self.connection.execute %Q(
      CREATE OR REPLACE VIEW kid_mentor_relations AS
        SELECT
          kids.id AS kid_id,
          kids.exit_kind AS kid_exit_kind,
          kids.exit_at AS kid_exit_at,
          mentors.id AS mentor_id,
          mentors.exit_kind AS mentor_exit_kind,
          mentors.exit_at AS mentor_exit_at,
          admins.id AS admin_id
        FROM
          kids
          INNER JOIN users AS mentors ON kids.mentor_id = mentors.id AND mentors.type = 'Mentor'
          LEFT JOIN users AS admins ON kids.admin_id = admins.id AND admins.type = 'Admin'
        WHERE
          kids.inactive = FALSE
        ;
    )
 end

  def down
    self.connection.execute "DROP VIEW IF EXISTS kid_mentor_relations;"
  end
end
