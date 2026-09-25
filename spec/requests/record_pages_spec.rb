# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Record pages' do
  let(:admin) { create(:admin) }
  let(:school) { create(:school, name: 'Alte Schule') }

  background { log_in(admin) }

  # The sidebar's and the mobile header's submit buttons sit outside the form
  # and reach it through its form_for default id (RecordHelper#submit_button).
  scenario 'every detached submit button targets a form on the page' do
    [new_school_path, edit_school_path(school), new_kid_path, edit_kid_path(create(:kid)),
     new_mentor_path, edit_mentor_path(create(:mentor)), edit_site_path].each do |path|
      visit path
      targets = all('button[form]', visible: :all).map { |button| button[:form] }
      expect(targets).not_to be_empty, "no detached submit button on #{path}"
      targets.uniq.each do |form_id|
        expect(page).to have_css("form##{form_id}", visible: :all), "#{path}: no form ##{form_id}"
      end
    end
  end

  scenario 'the sidebar submit button saves the record' do
    visit edit_school_path(school)
    fill_in 'school_name', with: 'Neue Schule'
    first("button[form='edit_school_#{school.id}']").click
    expect(school.reload.name).to eq('Neue Schule')
  end

  scenario 'shows the record name as the title of a show page' do
    visit school_path(school)
    expect(page).to have_css('h1', text: school.display_name)
  end
end

feature 'Index filter bar' do
  let(:admin) { create(:admin) }

  background { log_in(admin) }

  scenario 'offers the reset link for an applied filter that is not shown' do
    Site.load.update!(feature_coach: false)
    visit mentors_path(mentor: { filter_by_coach_id: admin.id })
    expect(page).to have_no_css('.dropdown-toggle', text: 'Pädagogischer Coach')
    expect(page).to have_link('Filter zurücksetzen')
  end

  scenario 'treats the default active filter as unfiltered' do
    visit mentors_path(mentor: { inactive: '0' })
    expect(page).to have_no_link('Filter zurücksetzen')
    visit mentors_path(mentor: { inactive: 'false', transport: '' })
    expect(page).to have_no_link('Filter zurücksetzen')
  end
end

feature 'Session timeout' do
  scenario 'lands on the sign-in page with a message' do
    admin = create(:admin)
    # without remember-me, which would otherwise keep the session alive
    visit new_user_session_path
    fill_in 'user_email', with: admin.email
    fill_in 'user_password', with: admin.password
    uncheck 'Angemeldet bleiben'
    click_button 'Anmelden'
    expect(page).to have_text('Erfolgreich angemeldet')

    # Devise flashes a boolean :timedout marker next to the alert message
    allow_any_instance_of(User).to receive(:timedout?).and_return(true) # rubocop:disable RSpec/AnyInstance
    visit kids_path
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_button('Anmelden')
  end
end
