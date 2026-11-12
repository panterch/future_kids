# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Index filter bar' do
  let(:admin) { create(:admin) }

  background { log_in(admin) }

  scenario 'offers the reset link for an applied filter that is not shown' do
    Site.load.update!(feature_coach: false)
    visit mentors_path(mentor: { filter_by_coach_id: admin.id })
    expect(page).to have_link('Filter zurücksetzen')
    expect(page).to have_no_css('.dropdown-toggle', text: 'Pädagogischer Coach')
  end

  scenario 'treats the default active filter as unfiltered' do
    visit mentors_path(mentor: { inactive: '0' })
    expect(page).to have_css('.dropdown-toggle')
    expect(page).to have_no_link('Filter zurücksetzen')
    visit mentors_path(mentor: { inactive: 'false', school_id: '' })
    expect(page).to have_css('.dropdown-toggle')
    expect(page).to have_no_link('Filter zurücksetzen')
  end
end
