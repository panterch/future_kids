require 'requests/acceptance_helper'

shared_examples 'schedule editing' do |label, path_helper, person_factory|
  let!(:admin) { create(:admin) }
  let!(:person) { create(person_factory) }

  background do
    log_in(admin)
    visit send(path_helper, person)
  end

  describe "#{label} schedule" do
    scenario 'checking a slot saves the schedule' do
      first('form.schedule input[type=checkbox]').check

      click_button 'Stundenplandaten speichern'

      expect(person.reload.schedules.count).to eq(1)
      schedule = person.reload.schedules.first
      expect(schedule.day).to eq(1)
      expect(schedule.hour).to eq(13)
      expect(schedule.minute).to eq(0)
    end

    scenario 'unchecking a slot removes the schedule' do
      create(:schedule, person: person, day: 1, hour: 14, minute: 0)
      visit send(path_helper, person)

      # Use the full "14:00 - 14:30" text to avoid matching the "13:30 - 14:00" row
      within find('tr', text: '14:00 - 14:30') do
        first('input[type=checkbox]').uncheck
      end

      click_button 'Stundenplandaten speichern'

      expect(person.reload.schedules.count).to eq(0)
    end

    scenario 'JS disables hidden inputs for unchecked slots on page load' do
      # All slots unchecked — JS should disable the sibling hidden inputs
      # so they are not submitted. This verifies register_schedule_checkboxes
      # ran on page load. Use have_no_selector (with built-in wait) to ensure
      # we don't race with JS execution.
      expect(page).to have_no_selector('form.schedule table input[type=hidden]:not([disabled])',
                                       visible: :all)
    end
  end
end

feature 'Edit schedules as Admin', js: true do
  it_behaves_like 'schedule editing', 'kid',    :edit_schedules_kid_path,    :kid
  it_behaves_like 'schedule editing', 'mentor', :edit_schedules_mentor_path, :mentor
end
