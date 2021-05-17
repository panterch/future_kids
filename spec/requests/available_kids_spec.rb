require 'requests/acceptance_helper'

feature 'AvailableKids as Mentor', js: true do

  before do
    create(:kid, name: 'Hodler Rolf', sex: 'm', longitude: 14.1025379, latitude: 50.1478497, grade: '1')
    create(:kid, name: 'Maria Rolf', sex: 'f', longitude: 14.1025379, latitude: 50.1478497, grade: '5')
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

  describe 'Available kids for filter grade_group' do
    before do
      log_in(create(:mentor, sex: 'f'))
      visit available_kids_path
    end

    scenario 'mentor can see one kid with grade 1' do
      select('Unterstufe', from: 'grade_group')
      expect(page).to have_content('Hodler Rolf')
      expect(page).not_to have_content('Maria Rolf')
    end

    scenario 'mentor can see one kid with grade 5' do
      select('Mittelstufe', from: 'grade_group')
      expect(page).not_to have_content('Hodler Rolf')
      expect(page).to have_content('Maria Rolf')
    end
  end
end
