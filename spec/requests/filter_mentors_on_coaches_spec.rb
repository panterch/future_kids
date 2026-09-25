# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Mentor index' do
  background do
    @pw      = 'welcome'
    @admin1  = create(:admin, name: 'first', prename: 'admin', password: @pw, password_confirmation: @pw)
    @admin2  = create(:admin, name: 'second', prename: 'admin')
    @mentor1 = create(:mentor, name: 'first', prename: 'mentor', transport: 'Halbtax')
    @mentor2 = create(:mentor, name: 'second', prename: 'mentor', transport: 'GA')
    @kid1    = create(:kid, mentor: @mentor1, admin: @admin1)
    @kid2    = create(:kid, mentor: @mentor1, admin: @admin2)
    @kid3    = create(:kid, mentor: @mentor1, admin: @admin1)
    @kid4    = create(:kid, mentor: @mentor1, admin: @admin2)
    @kid5    = create(:kid, mentor: @mentor2, admin: @admin2)
    @kid6    = create(:kid, mentor: @mentor2, admin: @admin2)
    log_in(@admin1)
    click_link 'Mentor*in'
  end

  scenario 'should filter mentors on coaches without repetitions' do
    choose_filter('Pädagogischer Coach', 'first, admin')
    expect(page).to have_text('1 Mentor*innen')
    expect(page).to have_css('a', text: 'first, mentor')
    choose_filter('Pädagogischer Coach', 'second, admin')
    expect(page).to have_text('2 Mentor*innen')
    expect(page).to have_css('a', text: 'first, mentor')
    expect(page).to have_css('a', text: 'second, mentor')
  end

  scenario 'other filters should not be affected' do
    choose_filter('ÖV', 'Regenbogen Kanton')
    expect(page).to have_text('0 Mentor*innen')
  end

  scenario 'filtering on coaches should interact with other filters (other chosen first)' do
    choose_filter('ÖV', 'GA')
    expect(page).to have_text('1 Mentor*innen')
    expect(page).to have_css('a', text: 'second, mentor')
    choose_filter('Pädagogischer Coach', 'first, admin')
    expect(page).to have_text('0 Mentor*innen')
  end

  scenario 'filtering on coaches should interact with other filters (other chosen last, no modification)' do
    choose_filter('Pädagogischer Coach', 'first, admin')
    expect(page).to have_text('1 Mentor*innen')
    expect(page).to have_css('a', text: 'first, mentor')
    choose_filter('ÖV', 'Halbtax')
    expect(page).to have_text('1 Mentor*innen')
    expect(page).to have_css('a', text: 'first, mentor')
  end

  scenario 'filtering on coaches should interact with other filters (other chosen last, with modification)' do
    choose_filter('Pädagogischer Coach', 'second, admin')
    expect(page).to have_text('2 Mentor*innen')
    expect(page).to have_css('a', text: 'first, mentor')
    expect(page).to have_css('a', text: 'second, mentor')
    choose_filter('ÖV', 'GA')
    expect(page).to have_text('1 Mentor*innen')
    expect(page).to have_css('a', text: 'second, mentor')
  end
end
