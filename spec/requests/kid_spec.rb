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

  describe 'meeting time' do
    before do
      click_link 'Schüler*in'
      click_link 'Hodler Rolf'
      click_link 'Bearbeiten'
    end

    scenario 'can be set to an arbitrary time' do
      fill_in 'Treffen beginnt um', with: '18:00'
      click_button 'Schüler*in aktualisieren'
      expect(Kid.find_by(name: 'Hodler Rolf').meeting_start_at.strftime('%H:%M')).to eq('18:00')

      click_link 'Bearbeiten'
      fill_in 'Treffen beginnt um', with: '15:20'
      click_button 'Schüler*in aktualisieren'
      expect(Kid.find_by(name: 'Hodler Rolf').meeting_start_at.strftime('%H:%M')).to eq('15:20')
    end

    scenario 'can be cleared' do
      Kid.find_by(name: 'Hodler Rolf').update!(meeting_start_at: '18:00')
      refresh
      fill_in 'Treffen beginnt um', with: ''
      click_button 'Schüler*in aktualisieren'
      expect(Kid.find_by(name: 'Hodler Rolf').meeting_start_at).to be_nil
    end
  end
end
