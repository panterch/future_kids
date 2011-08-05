require "spec/requests/acceptance_helper"

feature "SESSION::LOGIN", %q{
  As a mentor
  I want to have a login form
  So that I can login
} do

  background do
    @pw = 'spec12378'
    @mentor = Factory(:mentor, :password => @pw, :password_confirmation => @pw)
  end

  scenario "should login the user w/ valid credentials" do
    visit new_user_session_path
    fill_in 'user_email',    :with => @mentor.email
    fill_in 'user_password', :with => @pw
    click_button 'user_submit'
    page.should have_content('Angemeldet als')
  end

end
