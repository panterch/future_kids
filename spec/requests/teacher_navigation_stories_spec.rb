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
    expect(page.status_code).to eq(200)
    expect(page).to have_text('Zur Zeit sind Ihnen keine Kinder zugeordnet.')
  end

  scenario "should show a list with last and first name of the students" do
    @student1 = create(:kid, name: 'last1', prename: 'first1', teacher: @teacher)
    click_link 'Schüler/in'
    expect(page.status_code).to eq(200)
    expect(page).to have_text ('last1 first1')
  end

  scenario "should show student details when click on a student" do
    @student1 = create(:kid, name: 'last1', prename: 'first1', teacher: @teacher)
    @student2 = create(:kid, name: 'last2', prename: 'first2', teacher: @teacher)
    click_link 'Schüler/in'
    click_link 'last1 first1'
    expect(page).to have_css('h1', text: 'last1 first1')
    expect(page).to have_css('h2', text: 'Allgemeine Informationen')
    expect(page).to have_css('h2', text: 'Lernjournale')
  end

end
