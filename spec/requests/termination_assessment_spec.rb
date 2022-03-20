require 'requests/acceptance_helper'

feature 'TEACHER::CREATE:TERMINATION_ASSESSMENT', '
  As a teach
  I want to fill out the first year assessment form
  So that I can create a new kid
' do
  background do
    @teacher = create(:teacher)
    @admin = create(:admin)
    @kid = create(:kid, teacher: @teacher, admin: @admin)
    log_in(@teacher)
    visit kid_path(@kid)
  end

  scenario 'fill in default data value' do
    click_link 'Neues Abschluss-Feedback'
    expect(page.status_code).to eq(200)
    expect(find_field('* Lehrperson', type: :select).text).to match(@teacher.name)
  end

  scenario 'should create a new assessment with required values' do
    click_link 'Neues Abschluss-Feedback'
    expect {
      click_button 'Abschluss-Feedback erstellen'
    }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    expect(page.status_code).to eq(200)
    expect(page).to have_css('h4', text: 'Abschluss-Feedback vom ')
  end


end
