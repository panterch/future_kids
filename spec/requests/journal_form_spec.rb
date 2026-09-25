# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Journal form', :js do
  let(:mentor) { create(:mentor) }
  let(:kid) { create(:kid, mentor: mentor) }

  background do
    log_in(mentor)
    visit new_kid_journal_path(kid)
  end

  scenario 'hides the meeting times while the meeting is marked as cancelled' do
    expect(page).to have_field('journal_start_at')
    expect(page).to have_field('journal_end_at')

    check 'journal_cancelled'
    expect(page).to have_no_field('journal_start_at')
    expect(page).to have_no_field('journal_end_at')

    uncheck 'journal_cancelled'
    expect(page).to have_field('journal_start_at')
    expect(page).to have_field('journal_end_at')
  end
end
