# frozen_string_literal: true

require 'requests/acceptance_helper'

# The filters of the index pages are kept in the session (IndexFilters):
# coming back to the bare index path restores the last filter of that page.
feature 'Persistent index filters' do
  def current_query
    Rack::Utils.parse_nested_query(URI(current_url).query)
  end

  context 'as an admin' do
    background { log_in(create(:admin)) }

    {
      '/kids' => { 'kid' => { 'grade' => '3' } },
      '/mentors' => { 'mentor' => { 'inactive' => 'true' } },
      '/teachers' => { 'teacher' => { 'inactive' => 'true' } },
      '/admins' => { 'admin' => { 'inactive' => 'true' } },
      '/principals' => { 'principal' => { 'inactive' => 'true' } },
      '/schools' => { 'school' => { 'inactive' => 'true' } },
      '/reminders' => { 'reminder' => { 'filter_by_ects' => '1' } },
      '/kid_mentor_relations' => { 'kid_mentor_relation' => { 'simple_term' => 'Herbst' } }
    }.each do |path, filter|
      scenario "#{path} restores its filter after visiting another page" do
        visit "#{path}?#{filter.to_query}"
        visit '/'
        visit path

        expect(page).to have_current_path(path, ignore_query: true)
        expect(current_query).to eq(filter)
        expect(page).to have_link('Filter zurücksetzen')
      end
    end

    scenario 'the reset link drops the stored filter' do
      visit '/kids?kid[grade]=3'
      click_link 'Filter zurücksetzen'
      expect(page).to have_current_path('/kids')

      visit '/kids'
      expect(page).to have_current_path('/kids')
      expect(page).to have_no_link('Filter zurücksetzen')
    end

    scenario 'a new filter replaces the stored one, incl. the sort order' do
      visit '/kids?kid[grade]=3'
      visit '/kids?kid[grade]=4&order_by=created_at'
      visit '/kids'
      expect(current_query).to eq('kid' => { 'grade' => '4' }, 'order_by' => 'created_at')
    end

    scenario 'choosing "Alle" is stored as such' do
      visit '/kids?kid[grade]=3'
      visit '/kids?kid[grade]='
      visit '/kids'
      expect(current_query).to eq('kid' => { 'grade' => '' })
      expect(page).to have_no_link('Filter zurücksetzen')
    end

    scenario 'each index page keeps its own filter' do
      visit '/kids?kid[grade]=3'
      visit '/mentors'
      expect(page).to have_current_path('/mentors')
    end

    scenario 'order_by is kept for its own index page only' do
      visit '/kids?order_by=created_at'
      visit '/kid_mentor_relations'
      expect(page).to have_current_path('/kid_mentor_relations')
      visit '/kids'
      expect(current_query).to eq('order_by' => 'created_at')
    end

    scenario 'exports are not redirected' do
      visit '/kids?kid[grade]=3'
      visit '/kids.xlsx'
      expect(page).to have_current_path('/kids.xlsx')
    end

    scenario 'only whitelisted params are stored and the redirect stays on this host' do
      visit '/kids?kid[grade]=3&host=evil.example&redirect_to=https://evil.example'
      visit '/kids'
      expect(current_query).to eq('kid' => { 'grade' => '3' })
      expect(URI(current_url).host).not_to eq('evil.example')
    end

    scenario 'an oversized query is not stored and drops the previous one' do
      visit '/kids?kid[grade]=3'
      visit "/kids?order_by=#{'x' * (IndexFilters::MAX_QUERY_BYTES + 1)}"
      visit '/kids'
      expect(page).to have_current_path('/kids')
    end

    scenario 'logging out forgets the filters' do
      user = create(:admin)
      visit '/kids?kid[grade]=3'
      page.driver.submit :delete, destroy_user_session_path, {}
      log_in(user)
      visit '/kids'
      expect(page).to have_current_path('/kids')
    end
  end

  scenario 'a principal gets the kids filter restored' do
    log_in(create(:principal))
    visit '/kids?kid[grade]=3'
    visit '/kids'
    expect(current_query).to eq('kid' => { 'grade' => '3' })
  end

  scenario 'nothing is stored for users without a filter bar' do
    log_in(create(:teacher))
    visit '/kids?kid[grade]=3'
    visit '/kids'
    expect(page).to have_current_path('/kids')
  end

  # users without a filter bar must not filter by crafted params either - e.g.
  # a principal probing the admin-only note of the teachers they may list
  scenario 'filter params are ignored for users without a filter bar' do
    principal = create(:principal)
    school = principal.schools.first
    create(:teacher, school:, name: 'With Note', note: 'secret')
    create(:teacher, school:, name: 'Without Note')
    log_in(principal)

    visit '/teachers?teacher[note]=nomatch'
    expect(page).to have_text('With Note')
    expect(page).to have_text('Without Note')
    expect(page).to have_no_css('.dropdown-toggle', text: 'Aktiv')

    visit '/teachers'
    expect(page).to have_current_path('/teachers')
  end
end
