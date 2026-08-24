# frozen_string_literal: true

require 'requests/acceptance_helper'

# Covers the JS-response path (update.js.erb / destroy.js.erb) that
# manipulates the DOM without a page reload, as opposed to
# filter_reminders_spec.rb's non-:js coverage which only exercises the
# full-page-reload fallback.
feature 'reminders inline actions', :js do
  let!(:admin) { create(:admin) }
  let!(:reminder) { create(:reminder) }

  background do
    log_in(admin)
    visit reminders_path
  end

  scenario 'delivering a reminder removes the "Zustellen" button without reloading the page' do
    within('#reminders_table') do
      click_button 'Zustellen'
      expect(page).to have_no_button('Zustellen')
      expect(page).to have_text(reminder.kid.name)
    end
    expect(page).to have_current_path(reminders_path, ignore_query: true)
  end

  scenario 'acknowledging a reminder removes its row without reloading the page' do
    within('#reminders_table') do
      click_button 'Quittieren'
      expect(page).to have_no_text(reminder.kid.name)
    end
    expect(page).to have_current_path(reminders_path, ignore_query: true)
    expect(reminder.reload.acknowledged_at).to be_present
  end
end
