require "requests/acceptance_helper"

feature "TEACHER::NAVIGATION:KID", %q{
  As a teacher
  I want to navigate to the my students view
  So that I can get information's about my students
} do

  background do
    @pw = 'welcome'
    @teacher = create(:teacher, password: @pw, password_confirmation: @pw)
    log_in(@teacher)
  end

  scenario "when i click on the students navigation link i will see a list of my students" do
    click_link 'Schüler/in'
    page.status_code.should == 200
    page.should have_css('h2', text: 'Schüler/innen')
  end

end
