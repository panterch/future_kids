# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

unless Mentor.count > 0
  Mentor.create!(:name => 'Haller', :prename => 'Frederik',
                 :email => 'mentor@example.com', :password => 'welcome',
                 :password_confirmation => 'welcome')
end

unless Admin.count > 0
  Admin.create!(:name => 'AOZ', :prename => 'Admin',
                :email => 'admin@example.com', :password => 'welcome',
                :password_confirmation => 'welcome')
end

unless Teacher.count > 0
  Teacher.create!(:name => 'Meckler', :prename => 'Janine',
                  :email => 'teacher@example.com', :password => 'welcome',
                  :password_confirmation => 'welcome')
end

unless Kid.count > 0
  Kid.create!(:name => 'Meier', :prename => 'Max')
  Kid.create!(:name => 'Hodler', :prename => 'Rolf')
  Kid.create!(:name => 'Schwarz', :prename => 'Sandra')
end
