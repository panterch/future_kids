Factory.define :user do |f|
  f.sequence(:name) { |n| "Name #{n}"}
  f.prename 'Prename'
  f.sequence(:email) { |n| "email_#{n}@example.com" }
  f.password 'welcome'
  f.password_confirmation 'welcome'
end

Factory.define :admin, :class => Admin, :parent => :user do |f|
end

Factory.define :mentor, :class => Mentor, :parent => :user do |f|
end

Factory.define :teacher, :class => Teacher, :parent => :user do |f|
end

Factory.define :kid do |f|
  f.sequence(:name) { |n| "Kid #{n}"}
  f.prename 'Prename'
end

