require "requests/acceptance_helper"

feature "TEACHER::CREATE:KID", %q{
  As a teacher
  I want to fill out the new kid form
  So that I can create a new kid
} do

  background do
    @pw = 'welcome'
    @teacher = Factory(:teacher, :password => @pw, :password_confirmation => @pw)
    log_in(@teacher)
  end

  scenario "should create a new kid with the required values only",
    click_link 'Schüler/in'
    click_link 'Neuer Eintrag'
    click_button 'submit'
    page.status_code.should == 200
    page.should have_content('Neuer Eintrag')
    page.should have_content('muss ausgefüllt werden')
  end


end

feature "ADMIN::CREATE:KID", %q{
  As a teacher
  I want to fill out the new kid form
  So that I can create a new kid
} do

  background do
    @pw = 'welcome'
    @admin = Factory(:admin, :password => @pw, :password_confirmation => @pw)
    log_in(@admin)
  end

  scenario "should create a new kid with the required values only",
    click_link 'Schüler/in'
    click_link 'Neuer Eintrag'
    click_button 'submit'
    page.status_code.should == 200
    page.should have_content('Neuer Eintrag')
    page.should have_content('muss ausgefüllt werden')
  end


end
