# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Availability filter and badge' do
  background do
    Site.load.update!(kids_schedule_hourly: true)
    @mentor_none = create(:mentor, name: 'Leer', prename: 'Mentor')
    @mentor_full = create(:mentor, name: 'Voll', prename: 'Mentor')
    7.times { |i| create(:schedule, person: @mentor_full, day: 1, hour: 13 + i, minute: 0) }
    @kid_none = create(:kid, name: 'Leer', prename: 'Kid')
    @kid_one = create(:kid, name: 'Eins', prename: 'Kid')
    create(:schedule, person: @kid_one)
    log_in(create(:admin))
  end

  scenario 'filters mentors' do
    click_link 'Mentor*in'
    choose_filter('Verfügbarkeiten', 'Noch keine Verfügbarkeit erfasst')
    expect(page).to have_css('a', text: 'Leer, Mentor')
    expect(page).to have_no_css('a', text: 'Voll, Mentor')
    choose_filter('Verfügbarkeiten', 'Verfügbarkeit erfasst', open: true)
    expect(page).to have_css('a', text: 'Voll, Mentor')
    expect(page).to have_no_css('a', text: 'Leer, Mentor')
  end

  scenario 'filters kids' do
    click_link 'Schüler*in'
    choose_filter('Verfügbarkeiten', 'Wenig Verfügbarkeit erfasst')
    expect(page).to have_css('a', text: 'Eins, Kid')
    expect(page).to have_no_css('a', text: 'Leer, Kid')
  end

  scenario 'kid index hides the filter if kids use the simplified schedule' do
    Site.load.update!(kids_schedule_hourly: false)
    click_link 'Schüler*in'
    expect(page).to have_no_text('Verfügbarkeiten')
  end

  scenario 'profiles show the badge for admins' do
    visit mentor_path(@mentor_full)
    expect(page).to have_css('.badge.text-bg-success', text: 'Verfügbarkeit erfasst')
    visit kid_path(@kid_none)
    expect(page).to have_css('.badge.text-bg-danger', text: 'Noch keine Verfügbarkeit erfasst')
    visit kid_path(@kid_one)
    expect(page).to have_css('.badge.text-bg-warning')
  end
end
