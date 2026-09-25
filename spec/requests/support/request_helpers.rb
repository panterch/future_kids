# frozen_string_literal: true

def log_in(user, _options = {})
  visit new_user_session_path
  fill_in 'user_email', with: user.email
  fill_in 'user_password', with: user.password
  click_button 'Anmelden'
  expect(page).to have_text('Erfolgreich angemeldet')
  user
end

# Picks an option from a filter dropdown of an index page's filter bar
# (application/_filter_dropdown). Each pick is a plain link that navigates
# with the filter applied; the dropdown is found by its toggle's label, which
# turns into "label: value" once a filter is set. In :js scenarios pass
# `open: true` to click the toggle first, as a user would -- the options are
# only visible (and clickable in a real browser) once the menu is open.
def choose_filter(label, option, open: false)
  dropdown = all('.dropdown').find { |d| d.first('.dropdown-toggle')&.text&.split(': ')&.first == label }
  raise Capybara::ElementNotFound, "Unable to find filter dropdown #{label.inspect}" unless dropdown

  dropdown.find('.dropdown-toggle').click if open
  dropdown.click_link(option, exact: true)
end
