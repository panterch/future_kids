require 'requests/acceptance_helper'

feature 'Kid Mentor planning', :js do
  let(:school_zhaw) do
    create(:school, name: 'ZHAW')
  end
  let(:school_primary_school) do
    create(:school, name: 'Primary School X')
  end
  let(:school_secondary_school) do
    create(:school, name: 'Secondary School X')
  end
  let(:kid) do
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
  end
  let!(:admin) { create(:admin) }
  let!(:mentor_frederik) do
    mentor = create(:mentor, prename: 'Frederik', name: 'Haller', sex: 'm')
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
  end
  let!(:mentor_melanie) do
    mentor = create(:mentor, prename: 'Melanie', name: 'Rohner', sex: 'f')
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
  end
  let!(:mentor_max) do
    mentor = create(:mentor, prename: 'Max', name: 'Steiner', sex: 'm')
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
  end

  let!(:mentor_sarah) do
    mentor = create(:mentor, prename: 'Sarah', name: 'Koller', sex: 'f')
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
  end
  let!(:mentor_5) { create(:mentor, prename: 'Mentor 5', name: 'Other') }
  let!(:mentor_6) { create(:mentor, prename: 'Mentor 6', name: 'Other') }
  let!(:mentor_7) { create(:mentor, prename: 'Mentor 7', name: 'Other') }
  let!(:mentor_8) { create(:mentor, prename: 'Mentor 8', name: 'Other') }
  let!(:mentor_9) { create(:mentor, prename: 'Mentor 9', name: 'Other') }
  let!(:mentor_10) { create(:mentor, prename: 'Mentor 10', name: 'Other') }
  let!(:mentor_11) { create(:mentor, prename: 'Mentor 11', name: 'Other') }
  let!(:mentor_12) { create(:mentor, prename: 'Mentor 12', name: 'Other') }
  let!(:mentor_13) { create(:mentor, prename: 'Mentor 13', name: 'Other') }

  background do
    log_in(admin)
    visit show_kid_mentors_schedules_kid_path(id: kid.id)
  end

  describe 'kid-mentor-schedules component' do
    scenario 'has a filter compoment' do
      within('.kid-mentor-schedules') do
        expect(page).to have_css('.filters')
      end
    end

    describe 'filter' do
      describe 'number-of-kids-filter' do
        # frederik has no kid assigned
        # melanie has one primary kid
        let(:mentor_melanie) { super().kids.push create(:kid) }
        # max has one secondary kid
        let(:mentor_max) { super().secondary_kids.push create(:kid) }
        # sarah has both
        let(:mentor_sarah) do
          super().kids.push create(:kid)
          super().secondary_kids.push create(:kid)
        end

        scenario 'initially is set to show only mentors with no kid assigned' do
          val = find(:css, '.filters [name="number-of-kids"]').value
          expect(val).to eq('no-kid')
        end

        scenario 'select only mentors with no kid' do
          select 'keinem Schüler zugewiesen', from: 'number-of-kids'
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_no_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
        end

        scenario 'select only mentors with 1 primary kid assigned' do
          select 'nur primärem Schüler zugewiesen', from: 'number-of-kids'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
        end

        scenario 'select mentors with only one secondary kid assigned' do
          select 'nur sekundärem Schüler', from: 'number-of-kids'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_no_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
        end

        scenario 'show mentors with primary and secondary kid assigned' do
          select 'primärem und sekundärem Schüler', from: 'number-of-kids'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Rohner Melanie'
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
          select 'Männlich', from: 'sex'
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_no_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
        end

        scenario 'select only female mentors' do
          select 'Weiblich', from: 'sex'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
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

        it 'has a button to clear the selection' do
          within('.mentors-display-filter') do
            find('.Select-clear').click
            expect(find('.Select-control')).to have_no_content 'Haller Frederik'
            expect(find('.Select-control')).to have_no_content 'Rohner Melanie'
            expect(find('.Select-control')).to have_no_content 'Steiner Max'
            expect(find('.Select-control')).to have_no_content 'Koller Sarah'
          end
        end

        it 'allows to type in the beginning of a name to select it' do
          within('.mentors-display-filter') do
            find('.Select-clear').click
            find('.Select-input input').set('Hall')
            expect(find('.Select-menu')).to have_content 'Haller Frederik'
          end
        end

        it 'allows to type in the middle part of a name to select it' do
          within('.mentors-display-filter') do
            find('.Select-clear').click
            find('.Select-input input').set('lanie')
            expect(find('.Select-menu')).to have_content 'Rohner Melanie'
          end
        end
      end

      describe 'school-filter' do
        # frederik's kids go to zhaw and to the secondary school
        let(:mentor_frederik) do
          kid = create(:kid, school: school_zhaw)
          super().kids.push kid
          kid = create(:kid, school: school_secondary_school)
          super().kids.push kid
        end
        # melanie's kids go to the primary school and to the secondary school
        let(:mentor_melanie) do
          kid = create(:kid, school: school_primary_school)
          super().kids.push kid
          kid = create(:kid, school: school_secondary_school)
          super().kids.push kid
        end
        # max's kid goes to zhaw
        let(:mentor_max) do
          kid = create(:kid, school: school_zhaw)
          super().kids.push kid
        end

        background do
          # we need to select the filter with mentors with primary kids
          select 'nur primärem Schüler zugewiesen', from: 'number-of-kids'
        end
        # sarah has no kid in this spec

        scenario 'initially is set to show mentors of all schools' do
          val = find(:css, '.filters [name="school"]').value
          expect(val).to eq('')
        end

        scenario 'select only mentors from zhaw' do
          select school_zhaw.name, from: 'school'
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_no_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
        end

        scenario 'select only mentors from the secondary school' do
          select school_secondary_school.name, from: 'school'
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
          select 'Weiblich', from: 'sex'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
        end

        scenario 'select only mentors from the primary school' do
          select 'Männlich', from: 'sex'
          within('.kid-mentor-schedules') do
            expect(page).to have_content 'Haller Frederik'
            expect(page).to have_no_content 'Rohner Melanie'
            expect(page).to have_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
          select school_primary_school.name, from: 'school'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_no_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
          end
          select 'Weiblich', from: 'sex'
          within('.kid-mentor-schedules') do
            expect(page).to have_no_content 'Haller Frederik'
            expect(page).to have_content 'Rohner Melanie'
            expect(page).to have_no_content 'Steiner Max'
            expect(page).to have_no_content 'Koller Sarah'
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
          expect(page).to have_no_content '12:30'
          expect(page).to have_content '13:00'
          expect(page).to have_content '13:30'
          expect(page).to have_content '14:00'
          expect(page).to have_content '18:00'
          expect(page).to have_content '18:30'
          expect(page).to have_content '19:00'
          expect(page).to have_no_content '19:30'
        end
      end

      it 'allows hiding the weekdays' do
        # TODO: also test if entire column gets hidden
        within('.timetable') do
          days = %w[Montag Dienstag Mittwoch Donnerstag]
          for week_day in days
            day = find('.clickable_dayLabel.' + week_day)
            expect(day).to have_content week_day
            day.click
            expect(day).to have_no_content week_day
            day.click
            expect(day).to have_content week_day
          end
        end
      end

      it 'shows a column box per mentor per time if active' do
        within('.timetable') do
          expect(page).to have_css('.cell-mentor', count: 12 * 4)
        end
      end

      scenario 'select female mentors' do
        select 'Weiblich', from: 'sex'
        within('.timetable') do
          expect(page).to have_css('.cell-mentor', count: 24)
        end
      end

      it 'shows maximum 10 mentors' do
        within first('.timetable .time-cell.kid-available') do
          expect(page).to have_css('.column', count: 10)
        end
      end

      scenario 'a set meeting is visually indicated', :modal do
        # TOOD: did not know how to assign the mentor to the kid directly
        # so it just klicks through it

        within('.timetable') do
          message = accept_alert do
            first('.kid-available .cell-mentor .btn-set-date').click
          end
          expect(message).to include('primärer Mentor')
        end
        find('a', text: 'Mentor finden').click

        # Check if meeting is visually indicated
        within('.timetable') do
          expect(page).to have_css('.kid-booked', count: 1)
        end
      end

      describe 'selection of mentors' do
        scenario 'if the kid has no mentor assigned, it will be assign as primary mentor', :modal do
          within('.timetable') do
            message = accept_alert do
              first('.kid-available .cell-mentor .btn-set-date').click
            end
            expect(message).to include('primärer Mentor')
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
            expect(page).to have_content 'Haller, Frederik'
          end
          within('.kid_secondary_mentor') do
            expect(page).to have_content ''
          end
        end

        scenario 'if the kid has already a mentor assigned, it will be assign as secondary mentor', :modal do
          # TOOD: did not know how to assign the mentor to the kid directly
          # so it just klicks through it

          within('.timetable') do
            message = accept_alert do
              first('.kid-available .cell-mentor .btn-set-date').click
            end
            expect(message).to include('primärer Mentor')
          end
          find('a', text: 'Mentor finden').click

          within('.timetable') do
            message = accept_alert do
              first('.kid-available .cell-mentor .btn-set-date').click
            end
            expect(message).to include('Ersatzmentor')
          end

          within('.kid_mentor') do
            expect(page).to have_content 'Haller, Frederik'
          end
          within('.kid_secondary_mentor') do
            expect(page).to have_content 'Steiner, Max'
          end
        end

        describe 'if a selected mentor is already in that role for another kid, show an alert' do
          # melanie has primary kid
          let(:mentor_melanie) { super().kids.push create(:kid, name: 'Ende', prename: 'Momo') }
          # max has secondary kid
          let(:mentor_max) { super().secondary_kids.push create(:kid, name: 'Tolkien', prename: 'Pippin') }

          scenario 'the selected mentor is primary mentor for another kid', :modal do
            select 'nur primärem Schüler zugewiesen', from: 'number-of-kids'

            within('.timetable') do
              message = accept_alert do
                first('.kid-available .cell-mentor .btn-set-date').click
              end
              expect(message).to include('primärer Mentor')
              expect(message).to include('Ende Momo')
            end
          end

          scenario 'the selected mentor is secondary mentor for another kid', :modal do
            # TOOD: did not know how to assign the mentor to the kid directly
            # so it just klicks through it

            within('.timetable') do
              message = accept_alert do
                first('.kid-available .cell-mentor .btn-set-date').click
              end
              expect(message).to include('primärer Mentor')
            end
            find('a', text: 'Mentor finden').click

            select 'nur sekundärem Schüler', from: 'number-of-kids'

            within('.timetable') do
              message = accept_alert do
                first('.kid-available .cell-mentor .btn-set-date').click
              end
              expect(message).to include('Ersatzmentor')
              expect(message).to include('Tolkien Pippin')
            end
          end
        end
      end
    end
  end
end
