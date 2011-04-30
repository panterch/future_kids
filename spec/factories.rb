Factory.define :mentor do |f|
  f.sequence(:email) { |n| "mentor_#{n}@example.com" }
  f.password 'welcome'
  f.password_confirmation 'welcome'
end

Factory.define :admin do |f|
  f.sequence(:email) { |n| "admin_#{n}@example.com" }
  f.password 'welcome'
  f.password_confirmation 'welcome'
end

Factory.define :kid do |f|
end

