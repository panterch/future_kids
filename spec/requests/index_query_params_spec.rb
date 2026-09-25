# frozen_string_literal: true

require 'requests/acceptance_helper'

# The index toolbar and filter bar are built from the request's own query
# string, which is user input.
feature 'Index pages with crafted query params' do
  background { log_in(create(:admin)) }

  scenario 'the Excel export link stays on this host' do
    visit '/kids?host=evil.example&kid[term]=2014+Herbst'
    href = find_link('Excel Export')[:href]
    expect(href).to start_with('/kids.xlsx?')
    expect(href).not_to include('evil.example/')
    expect(Rack::Utils.parse_nested_query(URI(href).query)).to include('kid' => { 'term' => '2014 Herbst' })
  end

  scenario 'unknown filter keys are ignored, not called' do
    expect_any_instance_of(Kid).not_to receive(:save) # rubocop:disable RSpec/AnyInstance
    visit '/kids?kid[save]=1&kid[inactive]=0'
    expect(page).to have_css('h1', text: 'Schüler*innen')
    expect(page).to have_no_link('Filter zurücksetzen')
  end

  scenario 'known filter keys still count as active' do
    visit '/kids?kid[meeting_day]=1'
    expect(page).to have_link('Filter zurücksetzen')
  end
end
