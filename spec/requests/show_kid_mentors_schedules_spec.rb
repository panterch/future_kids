require 'requests/acceptance_helper'

feature 'React JS Hello World', js: true do
  let(:kid) { create(:kid) }
  let(:admin) { create(:admin) }

  scenario 'shows hello world' do
    log_in(admin)
    visit show_kid_mentors_schedules_kid_path(id: kid.id)
    expect(page).to have_content('Hello John')
  end

end
