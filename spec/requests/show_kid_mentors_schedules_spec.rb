require 'requests/acceptance_helper'

feature 'Kid Mentor planning', js: true do
  let(:school_zhaw) {
    create(:school, name: 'ZHAW')
  }
  let(:school_primary_school) {
    create(:school, name: 'Primary School X')
  }
  let(:kid) {
    kid = create(:kid)

    kid.schedules.create(day: 1, hour: 16, minute: 0)
    kid.schedules.create(day: 1, hour: 16, minute: 30)
    kid.schedules.create(day: 1, hour: 17, minute: 0)
    kid.schedules.create(day: 1, hour: 17, minute: 30)
    kid.schedules.create(day: 1, hour: 18, minute: 0)
    kid.schedules.create(day: 1, hour: 18, minute: 30)

    kid.schedules.create(day: 2, hour: 15, minute: 0)
    kid.schedules.create(day: 2, hour: 15, minute: 30)
    kid.schedules.create(day: 2, hour: 16, minute: 0)
    kid.schedules.create(day: 2, hour: 16, minute: 30)
    kid.schedules.create(day: 2, hour: 17, minute: 0)
    kid.schedules.create(day: 2, hour: 17, minute: 30)

    kid.schedules.create(day: 3, hour: 15, minute: 30)
    kid.schedules.create(day: 3, hour: 16, minute: 0)
    kid.schedules.create(day: 3, hour: 16, minute: 30)
    kid.schedules.create(day: 3, hour: 17, minute: 0)
    kid.schedules.create(day: 3, hour: 17, minute: 30)
    kid.schedules.create(day: 3, hour: 18, minute: 0)
    kid
  }
  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) {
    # Frederik receives ects
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
    mentor
  }
  let!(:mentor_melanie) {
    # melanie receives ects
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
    mentor
  }
  let!(:mentor_max) {
    # max does not receive ects
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
    mentor
  }

  let!(:mentor_sarah) {

    # sarah does not receive ects
    mentor =create(:mentor, ects: false, prename: 'Sarah', name: 'Koller', sex: 'f')
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
    mentor
  }
  let!(:mentor_5) {create(:mentor, prename: 'Mentor 5', name: 'Other')}
  let!(:mentor_6) {create(:mentor, prename: 'Mentor 6', name: 'Other')}
  let!(:mentor_7) {create(:mentor, prename: 'Mentor 7', name: 'Other')}
  let!(:mentor_8) {create(:mentor, prename: 'Mentor 8', name: 'Other')}
  let!(:mentor_9) {create(:mentor, prename: 'Mentor 9', name: 'Other')}
  let!(:mentor_10) {create(:mentor, prename: 'Mentor 10', name: 'Other')}
  let!(:mentor_11) {create(:mentor, prename: 'Mentor 11', name: 'Other')}
  let!(:mentor_12) {create(:mentor, prename: 'Mentor 12', name: 'Other')}
  let!(:mentor_13) {create(:mentor, prename: 'Mentor 13', name: 'Other')}


  background do
    expect(User.first.valid_password?(admin.password)).to eq(true)
    log_in(admin)
    visit show_kid_mentors_schedules_kid_path(id: kid.id)
  end

  describe 'kid-mentor-schedules component' do
    scenario 'has a filter compoment' do
      within('.kid-mentor-schedules') do
        expect(page).to have_selector('.filters')
      end
    end


    describe 'filter' do
      describe 'number-of-kids-filter' do

        # frederik has no kid assigned
        # melanie has one primary kid
        let(:mentor_melanie){super().kids.push create(:kid)}
        # max has one secondary kid
        let(:mentor_max){super().secondary_kids.push create(:kid)}
        # sarah has both
        let(:mentor_sarah){
          super().kids.push create(:kid)
          super().secondary_kids.push create(:kid)
        }


        scenario 'initially is set to show only mentors with no kid assigned' do
          val = find(:css, '.filters [name="number-of-kids"]').value
          expect(val).to eq('no-kid')
        end
        scenario 'select only mentors with no kid' do
          within('.filters [name="number-of-kids"]') do
            find('option[value="no-kid"]').click
          end

          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).not_to have_content 'Rohner Melanie'
            expect(page).not_to have_content 'Steiner Max'
            expect(page).not_to have_content 'Koller Sarah'
          end
        end
        scenario 'select only mentors with 1 primary kid assigned' do
          within('.filters [name="number-of-kids"]') do
            find('option[value="primary-only"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).not_to have_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).not_to have_content 'Steiner Max'
            expect(page).not_to have_content 'Koller Sarah'
          end
        end
        scenario 'select mentors with only one secondary kid assigned' do
          within('.filters [name="number-of-kids"]') do
            find('option[value="secondary-only"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).not_to have_content 'Haller Frederik'
            expect(page).not_to have_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).not_to have_content 'Koller Sarah'
          end
        end
        scenario 'show mentors with primary and secondary kid assigned' do
          within('.filters [name="number-of-kids"]') do
            find('option[value="primary-and-secondary"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).not_to have_content 'Haller Frederik'
            expect(page).not_to have_content 'Steiner Max'
            expect(page).not_to have_content 'Rohner Melanie'
            expect(page).to have_content 'Koller Sarah'
          end
        end
      end
      describe 'ects-filter' do


        scenario 'initially is set to show mentors with ects and without' do
          val = find(:css, '.filters [name="ects"]').value
          expect(val).to eq('')
        end
        scenario 'select ects' do
          within('.filters [name="ects"]') do
            find('option[value="true"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to_not have_content 'Steiner Max'
            expect(page).to_not have_content 'Koller Sarah'
          end
        end
        scenario 'select no ects' do
          within('.filters [name="ects"]') do
            find('option[value="false"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).to_not have_content 'Haller Frederik'
            expect(page).to_not have_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to have_content 'Koller Sarah'
          end
        end

      end

      describe 'sex-filter' do

        scenario 'initially is set to show both gender' do
          val = find(:css, '.filters [name="sex"]').value
          expect(val).to eq('')
        end
        scenario 'select only male mentors' do
          within('.filters [name="sex"]') do
            find('option[value="m"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to_not have_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to_not have_content 'Koller Sarah'
          end
        end
        scenario 'select only female mentors' do
          within('.filters [name="sex"]') do
            find('option[value="f"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).to_not have_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to_not have_content 'Steiner Max'
            expect(page).to have_content 'Koller Sarah'
          end
        end
      end
      describe 'mentors-display-filter' do
        it 'shows all the mentors initially' do
          within('.mentors-display-filter') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to have_content 'Koller Sarah'
          end
        end
        it 'has a button to clear the selection', :issue117 => true do
          within('.mentors-display-filter') do
            find('.Select-clear').click
            expect(page).to_not have_content 'Haller Frederik'
            expect(page).to_not have_content 'Rohner Melanie'
            expect(page).to_not have_content 'Steiner Max'
            expect(page).to_not have_content 'Koller Sarah'
          end
        end
        it 'allows to type in the beginning of a name to select it', :issue117 => true do
          within('.mentors-display-filter') do
            find('.Select-clear').click
            find('.Select-input input').set('Hall')
            expect(page).to have_content 'Haller Frederik'


          end
        end
        it 'allows to type in the middle part of a name to select it', :issue117 => true do
          within('.mentors-display-filter') do
            find('.Select-clear').click
            find('.Select-input input').set('lanie')
            expect(page).to have_content 'Rohner Melanie'


          end
        end
      end
      describe 'school-filter' do
        # frederik's kid goes to zhaw
        let(:mentor_frederik) {
          kid = create(:kid, school: school_zhaw)
          super().kids.push kid
        }
        # melanie's kid goes to the primary school
        let(:mentor_melanie) {
          kid = create(:kid, school: school_primary_school)
          super().kids.push kid
        }
        # max' kid goes also to zhaw
        let(:mentor_max) {
          kid = create(:kid, school: school_zhaw)
          super().kids.push kid
        }
        background do
          # we need to select the filter with mentors with primary kids
          within('.filters [name="number-of-kids"]') do
            find('option[value="primary-only"]').click
          end
        end
        # sarah has no kid in this spec

        scenario 'initially is set to show mentors of all schools' do
          val = find(:css, '.filters [name="school"]').value
          expect(val).to eq('')
        end

        scenario 'select only schools from zhaw' do
          within('.filters [name="school"]') do
            find('option[value="1"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to_not have_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to_not have_content 'Koller Sarah'
          end
        end
        scenario 'select only mentors from the primary school' do
          within('.filters [name="school"]') do
            find('option[value="2"]').click
          end
          within('.kid-mentor-schedules') do
            expect(page).to_not have_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to_not have_content 'Steiner Max'
            expect(page).to_not have_content 'Koller Sarah'
          end
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
          expect(page).to have_selector('.cell-mentor', count: 12*4)
        end
      end
      scenario 'select no ects' do
        within('.filters [name="ects"]') do
          find('option[value="false"]').click
        end
        within('.timetable') do
          expect(page).to have_selector('.cell-mentor', count: 12*2)
        end
      end

      scenario 'select female mentors with ects' do
        within('.filters [name="ects"]') do
          find('option[value="true"]').click
        end
        within('.filters [name="sex"]') do
          find('option[value="f"]').click
        end
        within('.timetable') do
          expect(page).to have_selector('.cell-mentor', count: 12)
        end
      end

      it 'shows maximum 10 mentors' do
        within first('.timetable .time-cell.kid-available') do
          expect(page).to have_selector('.column', count: 10)
        end
      end



      describe 'selection of mentors' do
        scenario 'if the kid has no mentor assigned, it will be assign as primary mentor' do
          within('.timetable') do
            first('.kid-available .cell-mentor .btn-set-date').click
            expect(page.driver.browser.switch_to.alert.text).to have_content 'primärer Mentor'
            page.driver.browser.switch_to.alert.accept
          end
          within('.kid_meeting_day') do
            expect(page).to have_content 'Dienstag'
          end
          within('.kid_meeting_start_at') do
            expect(page).to have_content '15:00'
          end
          within('.kid_meeting_start_at') do
            expect(page).to have_content '15:00'
          end
          within('.kid_mentor') do
            expect(page).to have_content 'Haller Frederik'
          end
          within('.kid_secondary_mentor') do
            expect(page).to have_content ''
          end
        end
        scenario 'if the kid has already a mentor assigned, it will be assign as secondary mentor' do
          # TOOD: did not know how to assign the mentor to the kid directly
          # so it just klicks through it

          within('.timetable') do
            first('.kid-available .cell-mentor .btn-set-date').click
            expect(page.driver.browser.switch_to.alert.text).to have_content 'primärer Mentor'
            page.driver.browser.switch_to.alert.accept

          end
          find('a', :text => 'Mentor finden').click

          within('.timetable') do
            first('.kid-available .cell-mentor .btn-set-date').click
            expect(page.driver.browser.switch_to.alert.text).to have_content 'Ersatzmentor'
            page.driver.browser.switch_to.alert.accept
          end


          within('.kid_mentor') do
            expect(page).to have_content 'Haller Frederik'
          end
          within('.kid_secondary_mentor') do
            expect(page).to have_content 'Steiner Max'
          end
        end

        describe 'if a selected mentor is already in that role for another kid, show an alert' do

          # melanie has primary kid
          let(:mentor_melanie){super().kids.push create(:kid, name: 'Ende', prename: 'Momo')}
          # max has secondary kid
          let(:mentor_max){super().secondary_kids.push create(:kid, name:'Tolkien', prename: 'Pippin')}


          scenario 'the selected mentor is primary mentor for another kid' do
            within('.filters [name="number-of-kids"]') do
              find('option[value="primary-only"]').click
            end

            within('.timetable') do
              first('.kid-available .cell-mentor .btn-set-date').click
              expect(page.driver.browser.switch_to.alert.text).to have_content 'primärer Mentor'
              expect(page.driver.browser.switch_to.alert.text).to have_content 'Ende Momo'
            end
          end
          scenario 'the selected mentor is secondary mentor for another kid' do
            # TOOD: did not know how to assign the mentor to the kid directly
            # so it just klicks through it

            within('.timetable') do
              first('.kid-available .cell-mentor .btn-set-date').click
              expect(page.driver.browser.switch_to.alert.text).to have_content 'primärer Mentor'
              page.driver.browser.switch_to.alert.accept

            end
            find('a', :text => 'Mentor finden').click

            within('.filters [name="number-of-kids"]') do
              find('option[value="secondary-only"]').click
            end

            within('.timetable') do
              first('.kid-available .cell-mentor .btn-set-date').click
              expect(page.driver.browser.switch_to.alert.text).to have_content 'Ersatzmentor'
              expect(page.driver.browser.switch_to.alert.text).to have_content 'Tolkien Pippin'
            end
          end
        end
      end
    end
  end
end
