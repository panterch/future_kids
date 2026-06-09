# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'Kids as Admin' do
  background do
    log_in(create(:admin))
  end

  before do
    create(:kid, name: 'Hodler Rolf')
  end

  describe 'simple schedules' do
    before do
      Site.load.update!(kids_schedule_hourly: false)
      click_link 'Schüler*in'
      click_link 'Hodler Rolf'
    end

    scenario 'Should see correct items' do
      expect(page).to have_no_text('Stundenplan bearbeiten')
      expect(page).to have_no_text('Mentor finden')
      expect(page).to have_no_text('Stundenplan aktualisiert')
      expect(page).to have_text('Verfügbare Zeiten')
    end

    scenario 'Should be able to set simple schedule' do
      click_link 'Bearbeiten'
      fill_in 'Verfügbare Zeiten', with: "I'm free between 3PM and 5PM everyday"
      click_button 'Schüler*in aktualisieren'
      expect(page).to have_text("I'm free between 3PM and 5PM everyday")
    end

    scenario "Shouldn't see simple schedule related things if site not configured" do
      Site.load.update!(kids_schedule_hourly: true)
      refresh

      expect(page).to have_no_text('Verfügbare Zeiten')
      click_link 'Bearbeiten'
      expect(page).to have_no_text('Verfügbare Zeiten')
    end
  end
end
