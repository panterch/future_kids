require "requests/acceptance_helper"

feature "SESSION::LOGIN", %q{
  As a mentor
  I want to have a login form
  So that I can login
} do

  background do
    @pw = 'spec12378'
    @mentor = create(:mentor, :password => @pw, :password_confirmation => @pw)
  end

  scenario "should login the user w/ valid credentials" do
    visit new_user_session_path
    fill_in 'user_email',    :with => @mentor.email
    fill_in 'user_password', :with => @pw
    click_button 'Anmelden'
    page.should have_content('Angemeldet als')
  end

  scenario "should not login the user w/ invalid credentials" do
    visit new_user_session_path
    fill_in 'user_email',    :with => @mentor.email
    fill_in 'user_password', :with => 'invalid'
    click_button 'Anmelden'
    page.should have_content('Ungültige Anmeldedaten')
  end

  scenario "should not login inactive users" do
    @mentor.update_attribute(:inactive, true)
    visit new_user_session_path
    fill_in 'user_email',    :with => @mentor.email
    fill_in 'user_password', :with => @pw
    click_button 'Anmelden'
    page.should have_content('Anmelden')
  end

end
