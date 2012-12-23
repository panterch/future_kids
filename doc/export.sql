# as user postgres in psql rails_production

COPY (SELECT

 id                     ,
 type                   ,
 name                   ,
 prename                ,
 address                ,
 phone                  ,
 personnel_number       ,
 field_of_study         ,
 education              ,
 available              ,
 etcs                   ,
 entry_date             ,
 created_at             ,
 updated_at             ,
 email                  ,
 sign_in_count          ,
 city                   ,
 transport              ,
 term                   ,
 dob                    ,
 inactive               ,
 zip                    ,
 street_no

FROM users) TO '/tmp/users.csv' WITH CSV HEADER;


COPY (SELECT

 kids.id                      ,
 kids.name                    ,
 kids.prename                 ,
 kids.parent                  ,
 kids.address                 ,
 kids.sex                     ,
 kids.grade                   ,
 kids.available               ,
 kids.entered_at              ,
 kids.meeting_day             ,
 kids.meeting_start_at        ,
 kids.created_at              ,
 kids.updated_at              ,
 kids.phone                   ,
 kids.secondary_active        ,
 kids.dob                     ,
 kids.language                ,
 kids.translator              ,
 kids.goal_1                  ,
 kids.goal_2                  ,
 kids.city                    ,
 kids.term                    ,
 kids.inactive                ,
 kids.zip                     ,
 kids.street_no,
 mentor.id "Mentor id",
 mentor.name "Mentor name",
 mentor.prename "Mentor prename",
 teacher.id "Teacher id",
 teacher.name "Teacher name",
 teacher.prename "Teacher prename"

FROM kids
LEFT JOIN users as mentor
ON kids.mentor_id = mentor.id
LEFT JOIN users as teacher
ON kids.teacher_id = teacher.id
) TO '/tmp/kids.csv' WITH CSV HEADER;
