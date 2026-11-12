# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

unless School.any?
  primary_school = School.create!(name: 'Primary school', school_kind: 'primary_school')
  gymnasium = School.create!(name: 'Gymnasium', school_kind: 'gymnasium')
  high_school = School.create!(name: 'High school', school_kind: 'high_school')
end

unless Mentor.any?
  Mentor.create!(name: 'Haller', prename: 'Frederik',
                 email: 'mentor@example.com', password: 'welcome',
                 password_confirmation: 'welcome', sex: 'm', school: gymnasium)
  Mentor.create!(name: 'Rohner', prename: 'Melanie',
                 email: 'mentor2@example.com', password: 'welcome',
                 password_confirmation: 'welcome', sex: 'f', school: gymnasium)
  Mentor.create!(name: 'Steiner', prename: 'Max',
                 email: 'mentor3@example.com', password: 'welcome',
                 password_confirmation: 'welcome', sex: 'm', school: high_school)
end

unless Admin.any?
  Admin.create!(name: 'AOZ', prename: 'Admin',
                email: 'admin@example.com', password: 'welcome',
                password_confirmation: 'welcome')
end

unless Teacher.any?
  Teacher.create!(name: 'Meckler', prename: 'Janine',
                  email: 'teacher@example.com', password: 'welcome',
                  password_confirmation: 'welcome', sex: 'f', school: primary_school)
end

unless Kid.any?
  Kid.create!(name: 'Meier', prename: 'Max', sex: 'm', goal_3: true, goal_25: true)
  Kid.create!(name: 'Hodler', prename: 'Rolf', sex: 'm', goal_3: true, goal_25: true)
  Kid.create!(name: 'Schwarz', prename: 'Sandra', sex: 'f', goal_3: true, goal_25: true)
end
