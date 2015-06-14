require 'requests/acceptance_helper'

feature 'Kid Mentor planning', js: true do
  let(:kid) { create(:kid) }
  let!(:admin) { create(:admin) }

  background do
    expect(User.first.valid_password?(admin.password)).to eq(true)
    log_in(admin)
    visit show_kid_mentors_schedules_kid_path(id: kid.id)
  end

  describe 'kit-mentor-schedules component' do
    it 'has a filter compoment' do
      within('.kit-mentor-schedules') do
        expect(page).to have_selector('.filters')
      end
    end

    it 'initially shows all mentors with no kid assigned' do
      within('.kit-mentor-schedules .filters .mentors') do
        expect(page).to have_content('Haller Frederik')
      end
    end



  end




end
