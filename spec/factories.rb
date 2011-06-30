Factory.define :user do |f|
  f.sequence(:name) { |n| "Name #{n}"}
  f.prename 'Prename'
  f.sequence(:email) { |n| "email_#{n}@example.com" }
  f.password 'welcome'
  f.password_confirmation 'welcome'
end

Factory.define :admin, :class => 'Admin', :parent => :user do |f|
  f.sequence(:email) { |n| "admin_#{n}@example.com" }
end

Factory.define :mentor, :class => 'Mentor', :parent => :user do |f|
  f.sequence(:email) { |n| "mentor_#{n}@example.com" }
end

Factory.define :teacher, :parent => :user do |f|
  f.sequence(:email) { |n| "teacher_#{n}@example.com" }
end

Factory.define :kid do |f|
  f.sequence(:name) { |n| "Kid #{n}"}
  f.prename 'Prename'
end

Factory.define :journal do |f|
  f.association :kid
  f.association :mentor
  f.held_at Date.parse("2011-05-30")
  f.start_at Time.parse("13:00")
  f.end_at Time.parse("14:00")
end

Factory.define :review do |f|
  f.association :kid
  f.held_at Date.parse("2011-05-30")
end

