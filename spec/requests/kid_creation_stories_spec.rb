require "requests/acceptance_helper"

feature "TEACHER::CREATE:KID", %q{
  As a teacher
  I want to fill out the new kid form
  So that I can create a new kid
} do

  background do
    @pw = 'welcome'
    @teacher = create(:teacher, password: @pw, password_confirmation: @pw)
    log_in(@teacher)
  end

  scenario "should not create a new kid without the required values" do
    click_link 'Schüler/in'
    click_link 'Neuer Eintrag'
    click_button 'Schüler/in erstellen'
    page.status_code.should == 200
    page.should have_content('Schüler/in erfassen')
    page.should have_content('muss ausgefüllt werden')
  end

  scenario "should create a new kid with required values" do
    click_link 'Schüler/in'
    click_link 'Neuer Eintrag'
    fill_in 'kid_name', with: 'Last Name'
    fill_in 'kid_prename', with: 'First Name'
    click_button 'Schüler/in erstellen'
    page.status_code.should == 200
    page.should have_css('h1', text: 'Last Name First Name')
  end

end

feature "ADMIN::CREATE:KID", %q{
  As a teacher
  I want to fill out the new kid form
  So that I can create a new kid
} do

  background do
    @pw = 'welcome'
    @admin = create(:admin, :password => @pw, :password_confirmation => @pw)
    log_in(@admin)
  end

  scenario "should not create a new kid without the required values" do
    click_link 'Schüler/in'
    click_link 'Neuer Eintrag'
    click_button 'Schüler/in erstellen'
    page.status_code.should == 200
    page.should have_content('Schüler/in erfassen')
    page.should have_content('muss ausgefüllt werden')
  end

  scenario "should create a new kid with required values" do
    click_link 'Schüler/in'
    click_link 'Neuer Eintrag'
    fill_in 'kid_name', with: 'Last Name'
    fill_in 'kid_prename', with: 'First Name'
    click_button 'Schüler/in erstellen'
    page.status_code.should == 200
    page.should have_css('h1', :text => 'Last Name First Name')
  end


end
