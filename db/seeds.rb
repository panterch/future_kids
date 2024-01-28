# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

schools = []
unless School.count > 0
  schools << School.create!(name: 'Primary school', school_kind: 'primary_school').id
  schools << School.create!(name: 'Secondary school', school_kind: 'secondary_school').id
  schools << School.create!(name: 'Gymnasium', school_kind: 'gymnasium').id
  schools << School.create!(name: 'High school', school_kind: 'high_school').id
end

unless Mentor.count > 0
  Mentor.create!(name: 'Haller', prename: 'Frederik',
                 email: 'mentor@example.com', password: 'welcome',
                 password_confirmation: 'welcome', sex: 'm', school_id: schools[2])
  Mentor.create!(name: 'Rohner', prename: 'Melanie',
                 email: 'mentor2@example.com', password: 'welcome',
                 password_confirmation: 'welcome', sex: 'f', school_id: schools[2])
  Mentor.create!(name: 'Steiner', prename: 'Max',
                 email: 'mentor3@example.com', password: 'welcome',
                 password_confirmation: 'welcome', sex:'m', school_id: schools[3])
end

unless Admin.count > 0
  Admin.create!(name: 'AOZ', prename: 'Admin',
                email: 'admin@example.com', password: 'welcome',
                password_confirmation: 'welcome')
end

unless Teacher.count > 0
  Teacher.create!(name: 'Meckler', prename: 'Janine',
                  email: 'teacher@example.com', password: 'welcome',
                  password_confirmation: 'welcome', sex: 'f', school_id: schools[0])
end

unless Kid.count > 0
  Kid.create!(name: 'Meier', prename: 'Max', sex: 'm', goal_3: true, goal_25: true)
  Kid.create!(name: 'Hodler', prename: 'Rolf', sex: 'm', goal_3: true, goal_25: true)
  Kid.create!(name: 'Schwarz', prename: 'Sandra', sex: 'f', goal_3: true, goal_25: true)
end
