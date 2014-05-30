require "requests/acceptance_helper"

feature "SESSION::LOGOUT:ADMIN", %q{
  As an administrator
  I want to have a logout link
  So that I can log out
} do

  background do
    @pw = 'spec12378'
    @admin = create(:admin, :password => @pw, :password_confirmation => @pw)
    log_in(@admin)
  end

  scenario "should show the login form after a logout" do
    click_link('abmelden')
    page.should have_content('Anmelden')
  end

end

feature "SESSION::LOGOUT:MENTOR", %q{
  As a mentor
  I want to have a logout link
  So that I can log out
} do

  background do
    @pw = 'spec12378'
    @mentor = create(:mentor, :password => @pw, :password_confirmation => @pw)
    log_in(@mentor)
  end

  scenario "should show the login form after a logout" do
    click_link('abmelden')
    page.should have_content('Anmelden')
  end

end

feature "SESSION::LOGOUT:TEACHER", %q{
  As a teacher
  I want to have a logout link
  So that I can log out
} do

  background do
    @pw = 'spec12378'
    @teacher = create(:teacher, :password => @pw, :password_confirmation => @pw)
    log_in(@teacher)
  end

  scenario "should show the login form after a logout" do
    click_link('abmelden')
    page.should have_content('Anmelden')
  end

end
