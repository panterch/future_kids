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

Factory.define :teacher, :class => 'Teacher', :parent => :user do |f|
  f.sequence(:email) { |n| "teacher_#{n}@example.com" }
end

Factory.define :principal, :class => 'Principal', :parent => :user do |f|
  f.sequence(:email) { |n| "principal_#{n}@example.com" }
  f.association :school
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

Factory.define :cancelled_journal, :parent => :journal do |f|
  f.held_at Date.parse("2011-05-30")
  f.cancelled true
  f.start_at nil
  f.end_at nil
end

Factory.define :review do |f|
  f.association :kid
  f.held_at Date.parse("2011-05-30")
end

Factory.define :reminder do |f|
  f.association :kid
  f.association :mentor
  f.recipient { |r| r.mentor.email }
  f.held_at Date.parse("2011-05-30")
  f.week { |r| r.held_at.strftime('%U') }
  f.year { |r| r.held_at.year }
end

Factory.define :schedule do |f|
  f.person {|p| p.association(:mentor) }
  f.day 1
  f.hour 14
  f.minute 0
end

Factory.define :school do |f|
  f.name "The school"
end

Factory.define :comment do |f|
  f.association :journal
  f.body "A comment"
  f.by "Commentator"
end

Factory.define :document do |f|

end
