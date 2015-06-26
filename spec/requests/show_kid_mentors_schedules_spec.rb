require 'requests/acceptance_helper'

feature 'Kid Mentor planning', js: true do
  let(:kid) { create(:kid) }
  let!(:admin) { create(:admin) }
  let!(:mentor_rederik) { create(:mentor, ects: true, prename: 'Frederik', name: 'Haller') }
  let!(:mentor_melanie) { create(:mentor, ects: true, prename: 'Melanie', name:'Rohner') }
  let!(:mentor_max) { create(:mentor, ects: false, prename: 'Max', name: 'Steiner') }

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
      within('.mentors-filtered') do
        expect(page).to have_content 'Frederik Haller'
        expect(page).to have_content 'Max Steiner'
        expect(page).to have_content 'Melanie Rohner'
      end
    end
    describe 'filter' do
     scenario 'select ects' do
       within('.filters') do
         page.select 'ECTS', :from => 'ects'
         page.execute_script '$(".filters [name=\'ects\']").trigger("change");'

       end
       within('.mentors-filtered') do

         expect(page).to have_content 'Frederik Haller'
         expect(page).to have_content 'Melanie Rohner'
         expect(page).to_not have_content 'Max Steiner'
       end
     end
     scenario 'select no ects' do
       within('.filters') do
         page.select 'nur nicht-ECTS', :from => 'ects'
         page.execute_script '$(".filters [name=\'ects\']").trigger("change");'
       end
       within('.mentors-filtered') do
         expect(page).to_not have_content 'Frederik Haller'
         expect(page).to_not have_content 'Melanie Rohner'
         expect(page).to have_content 'Max Steiner'
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
      it 'shows shows a column box per mentor per time if active' do
        within('.timetable') do
          expect(page).to have_selector('.box', count: 12)
        end


      end
    end



  end



end
