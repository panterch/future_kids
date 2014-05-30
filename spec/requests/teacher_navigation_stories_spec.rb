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

  scenario "should show message when no sudents" do
    click_link 'Schüler/in'
    page.status_code.should == 200
    page.should have_text('Zur Zeit sind Ihnen keine Kinder zugeordnet.')
  end

  scenario "should students details if the teacher has one studend assigned" do
    @student1 = create(:kid, name: 'last1', prename: 'first1', teacher: @teacher)
    click_link 'Schüler/in'
    page.status_code.should == 200
    page.should have_css('h1', text: 'last1 first1')
    page.should have_css('h2', text: 'Allgemeine Informationen')
    page.should have_css('h2', text: 'Lernjournale')
  end

  scenario "should show a list with last and first name of the students when the teacher has two or more students assigned" do
    @student1 = create(:kid, name: 'last1', prename: 'first1', teacher: @teacher)
    @student2 = create(:kid, name: 'last2', prename: 'first2', teacher: @teacher)
    click_link 'Schüler/in'
    page.status_code.should == 200
    page.should have_text ('last1 first1')
    page.should have_text ('last2 first2')
  end
end
