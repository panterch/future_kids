require 'requests/acceptance_helper'

feature 'Kid Mentor planning', js: true do
  let(:kid) { create(:kid) }
  let!(:admin) { create(:admin) }
  let!(:mentor_rederik) {
    mentor = create(:mentor, ects: true, prename: 'Frederik', name: 'Haller', sex: 'm')
    mentor.schedules.create(day: 1, hour: 14, minute: 0)
    mentor.schedules.create(day: 1, hour: 14, minute: 30)
    mentor.schedules.create(day: 1, hour: 15, minute: 0)
    mentor.schedules.create(day: 1, hour: 15, minute: 30)
    mentor.schedules.create(day: 1, hour: 16, minute: 0)
    mentor.schedules.create(day: 1, hour: 16, minute: 30)
    mentor.schedules.create(day: 2, hour: 14, minute: 0)
    mentor.schedules.create(day: 2, hour: 14, minute: 30)
    mentor.schedules.create(day: 2, hour: 15, minute: 0)
    mentor.schedules.create(day: 2, hour: 15, minute: 30)
    mentor.schedules.create(day: 2, hour: 16, minute: 0)
    mentor.schedules.create(day: 2, hour: 16, minute: 30)

  }
  let!(:mentor_melanmentorie) {
    mentor = create(:mentor, ects: true, prename: 'Melanie', name:'Rohner', sex: 'f')
    mentor.schedules.create(day: 3, hour: 14, minute: 0)
    mentor.schedules.create(day: 3, hour: 14, minute: 30)
    mentor.schedules.create(day: 3, hour: 15, minute: 0)
    mentor.schedules.create(day: 3, hour: 15, minute: 30)
    mentor.schedules.create(day: 3, hour: 16, minute: 0)
    mentor.schedules.create(day: 3, hour: 16, minute: 30)
    mentor.schedules.create(day: 5, hour: 14, minute: 0)
    mentor.schedules.create(day: 5, hour: 14, minute: 30)
    mentor.schedules.create(day: 5, hour: 15, minute: 0)
    mentor.schedules.create(day: 5, hour: 15, minute: 30)
    mentor.schedules.create(day: 5, hour: 16, minute: 0)
    mentor.schedules.create(day: 5, hour: 16, minute: 30)
  }
  let!(:mentor_max) {
    mentor =create(:mentor, ects: false, prename: 'Max', name: 'Steiner', sex: 'm')
    mentor.schedules.create(day: 1, hour: 17, minute: 0)
    mentor.schedules.create(day: 1, hour: 17, minute: 30)
    mentor.schedules.create(day: 1, hour: 18, minute: 0)
    mentor.schedules.create(day: 1, hour: 18, minute: 30)
    mentor.schedules.create(day: 1, hour: 19, minute: 0)
    mentor.schedules.create(day: 2, hour: 14, minute: 30)
    mentor.schedules.create(day: 2, hour: 15, minute: 0)
    mentor.schedules.create(day: 2, hour: 15, minute: 30)
    mentor.schedules.create(day: 2, hour: 16, minute: 0)
    mentor.schedules.create(day: 2, hour: 16, minute: 30)
    mentor.schedules.create(day: 2, hour: 17, minute: 0)
    mentor.schedules.create(day: 2, hour: 17, minute: 30)
  }

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
      within('.kit-mentor-schedules') do
        expect(page).to have_content 'Frederik Haller'
        expect(page).to have_content 'Max Steiner'
        expect(page).to have_content 'Melanie Rohner'
      end
    end
    describe 'filter' do
      scenario 'select ects' do
        within('.filters [name="ects"]') do
          find('option[value="true"]').click
        end
        within('.kit-mentor-schedules') do
          expect(page).to have_content 'Frederik Haller'
          expect(page).to have_content 'Melanie Rohner'
          expect(page).to_not have_content 'Max Steiner'
        end
      end
      scenario 'select no ects' do

        within('.filters [name="ects"]') do
          find('option[value="false"]').click
        end
        within('.kit-mentor-schedules') do
          expect(page).to_not have_content 'Frederik Haller'
          expect(page).to_not have_content 'Melanie Rohner'
          expect(page).to have_content 'Max Steiner'
        end
      end

      scenario 'select only male or only female mentors' do
        within('.filters [name="sex"]') do
          find('option[value="m"]').click
        end
        within('.kit-mentor-schedules') do
          expect(page).to have_content 'Frederik Haller'
          expect(page).to_not have_content 'Melanie Rohner'
          expect(page).to have_content 'Max Steiner'
        end
        within('.filters [name="sex"]') do
          find('option[value="f"]').click
        end
        within('.kit-mentor-schedules') do
          expect(page).to_not have_content 'Frederik Haller'
          expect(page).to have_content 'Melanie Rohner'
          expect(page).to_not have_content 'Max Steiner'
        end
      end
    end



    describe 'timetable' do
      it 'shows all weekdays' do
        within('.timetable') do
          expect(page).to have_content 'Montag'
          expect(page).to have_content 'Dienstag'
          expect(page).to have_content 'Mittwoch'
          expect(page).to have_content 'Donnerstag'
          expect(page).to have_content 'Freitag'
        end
      end
      it 'shows times from 13:00 to 19:00 with 30min intervals' do
        within('.timetable') do
          expect(page).to_not have_content '12:30'
          expect(page).to have_content '13:00'
          expect(page).to have_content '13:30'
          expect(page).to have_content '14:00'
          expect(page).to have_content '18:00'
          expect(page).to have_content '18:30'
          expect(page).to have_content '19:00'
          expect(page).to_not have_content '19:30'
        end
      end
      it 'shows a column box per mentor per time if active' do
        within('.timetable') do
          expect(page).to have_selector('.cell-mentor', count: 12*3)
        end
      end
      scenario 'select no ects' do
        within('.filters [name="ects"]') do
          find('option[value="false"]').click
        end
        within('.timetable') do
          expect(page).to have_selector('.cell-mentor', count: 12)
        end
      end

      scenario 'select one entry to store the date' do
        within('timetable') do
          find('.cell-mentor', :text => 'Frederik Haller').click
          #page.driver.browser.switch_to.alert.accept

        end
      end


    end
  end
end
