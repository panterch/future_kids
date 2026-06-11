# frozen_string_literal: true

FactoryBot.define do
  factory :first_year_assessment do
    kid
    teacher
    mentor
    created_by(&:mentor)
    held_at { Date.parse('2018-10-01') }
  end

  factory :termination_assessment do
    kid
    teacher
    created_by(&:teacher)
    held_at { Date.parse('2018-10-01') }
  end

  factory :substitution do
    mentor
    kid
    start_at { Date.parse('2015-11-13') }
    end_at { Date.parse('2015-11-14') }
  end

  factory :user do
    sequence(:name) { |n| "Name #{n}" }
    prename { 'Prename' }
    sequence(:email) { |n| "email_#{n}@example.com" }
    password { 'welcome' }
    password_confirmation { 'welcome' }
  end

  factory :admin, class: 'Admin', parent: :user do
    sequence(:email) { |n| "admin_#{n}@example.com" }
  end

  factory :mentor, class: 'Mentor', parent: :user do
    sequence(:email) { |n| "mentor_#{n}@example.com" }
    sequence(:name) { |n| "Mentor name#{n}" }
    sequence(:prename) { |n| "Mentor prename#{n}" }
    school
    photo { Rack::Test::UploadedFile.new(File.join('spec', 'fixtures', 'files', 'logo.png'), 'image/png') }
    sex { 'male' }
    address { 'address' }
    city { 'city' }
    dob { '1.1.1990' }
    phone { '123456798' }

    to_create { |instance| instance.save(validate: false) }
  end

  factory :teacher, class: 'Teacher', parent: :user do
    sequence(:email) { |n| "teacher_#{n}@example.com" }
    sequence(:name) { |n| "Mentor name#{n}" }
    sequence(:prename) { |n| "Mentor prename#{n}" }
    school
    phone { '123456798' }
  end

  factory :principal, class: 'Principal', parent: :user do
    sequence(:email) { |n| "principal_#{n}@example.com" }
    schools { [FactoryBot.create(:school)] }
  end

  factory :kid do
    sequence(:name) { |n| "Kid #{n}" }
    prename { 'Prename' }
    grade { 3 }
    sex { 'male' }
    language { 'Kroatisch' }
    parent { 'Nico' }
    address { 'Blumenweg 12' }
    city { '8005 Zürich' }
    phone { '123456789' }
    goal_1 { 'Ein fachliches Lernziel' }
    goal_2 { 'Ein überfachliches Lernziel' }
    simplified_schedule { 'immer nachmittags' }
  end

  factory :journal do
    kid
    mentor
    held_at { Date.parse('2011-05-30') }
    start_at { Time.zone.parse('13:00') }
    end_at { Time.zone.parse('14:00') }
    meeting_type { :physical }
  end

  factory :cancelled_journal, parent: :journal do
    held_at { Date.parse('2011-05-30') }
    cancelled { true }
    start_at { nil }
    end_at { nil }
  end

  factory :review do
    kid
    held_at { Date.parse('2011-05-30') }
  end

  factory :reminder do
    kid
    mentor
    recipient { |r| r.mentor.email }
    held_at { Date.parse('2011-05-30') }
    week { |r| r.held_at.strftime('%U') }
    year { |r| r.held_at.year }
  end

  factory :schedule do
    person { |p| p.association(:mentor) }
    day { 1 }
    hour { 14 }
    minute { 0 }
  end

  factory :school do
    name { 'The school' }
  end

  factory :comment do
    journal
    created_by factory: %i[user]
    body { 'A comment' }
    by { 'Commentator' }
  end

  factory :document do
    title { 'A document' }
  end

  factory :relation_log do
    kid
    user { |p| p.association(:mentor) }
  end

  factory :principal_school_relation do
    school
    principal
  end
end
