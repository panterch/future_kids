require 'requests/acceptance_helper'

feature 'MENTOR::CREATE:FIRST_YEAR_ASSESSMENT', '
  As a mentor
  I want to fill out the first year assessment form
  So that I can create a new kid
' do
  background do
    @mentor = create(:mentor, terms_of_use_accepted: true)
    @teacher = create(:teacher, terms_of_use_accepted: true)
    @admin = create(:admin, terms_of_use_accepted: true)
    @kid = create(:kid, mentor: @mentor, teacher: @teacher, admin: @admin)
    log_in(@mentor)
    visit kid_path(@kid)
  end

  scenario 'fill in default data value' do
    click_link 'Neues Auswertungsgespräch'
    expect(page.status_code).to eq(200)
    expect(find_field('* Lehrperson', type: :select).text).to match(@teacher.name)
    expect(find_field('* Mentor', type: :select).text).to match(@mentor.name)
  end

  scenario 'should create a new assessment with required values' do
    click_link 'Neues Auswertungsgespräch'
    expect {
      click_button 'Auswertungsgespräch erstellen'
    }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    expect(page.status_code).to eq(200)
    expect(page).to have_css('h4', text: 'Auswertungsgespräch vom ')
  end


end
