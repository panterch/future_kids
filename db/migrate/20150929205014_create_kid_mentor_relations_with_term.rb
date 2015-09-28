class CreateKidMentorRelationsWithTerm < ActiveRecord::Migration
  def up
    connection.execute 'DROP VIEW IF EXISTS kid_mentor_relations;'
    connection.execute %(
      CREATE OR REPLACE VIEW kid_mentor_relations AS
        SELECT
          kids.id AS kid_id,
          kids.exit_kind AS kid_exit_kind,
          kids.exit_at AS kid_exit_at,
          kids.school_id AS school_id,
          kids.name AS kid_name,
          mentors.id AS mentor_id,
          mentors.exit_kind AS mentor_exit_kind,
          mentors.exit_at AS mentor_exit_at,
          mentors.name AS mentor_name,
          admins.id AS admin_id,
          substring(kids.term, 6) AS simple_term
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
    connection.execute 'DROP VIEW IF EXISTS kid_mentor_relations;'
  end
end
