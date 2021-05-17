require 'requests/acceptance_helper'

feature 'AvailableKids as Mentor' do

  before do
    create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497)
    create(:kid, name: 'Maria Rolf', sex: 'f', longitude: 14.1025379, latitude: 50.1478497)
  end

  describe 'Available kids for men' do
    before do
      log_in(create(:mentor, sex: 'm', longitude: 14.0474263, latitude: 50.1873213))
      visit available_kids_path
    end

    scenario 'mentor can see one kid' do
      expect(page).to have_content('Hodler Rolf')
      expect(page).not_to have_content('Maria Rolf')
      expect(page).to have_content('5.89 km')
    end
  end

  describe 'Available kids for women' do
    before do
      log_in(create(:mentor, sex: 'f', longitude: 14.0474263, latitude: 50.1873213))
      visit available_kids_path
    end

    scenario 'mentor can see two kids' do
      expect(page).to have_content('Hodler Rolf')
      expect(page).to have_content('Maria Rolf')
      expect(page).to have_content('5.89 km')
    end
  end
end
