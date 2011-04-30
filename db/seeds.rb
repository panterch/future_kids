# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

unless Mentor.count > 0
  Mentor.create!(:email => 'mentor@example.com', :password => 'welcome',
                 :password_confirmation => 'welcome')
end

unless Admin.count > 0
  Admin.create!(:email => 'admin@example.com', :password => 'welcome',
                 :password_confirmation => 'welcome')
end

Kid.destroy_all
Kid.create!(:name => 'Future', :prename => 'Kid')
