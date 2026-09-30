# frozen_string_literal: true

require 'requests/acceptance_helper'

# Covers the inline "Aktueller Stand" dropdowns of the Bewegungen list end to
# end: the JS change handler, the PATCH request and the saved result. The
# rendering and the controller are covered in kid_mentor_relations_spec.rb and
# kid_mentor_relations_controller_spec.rb.
feature 'Bewegungen inline exit kind', :js do
  let!(:mentor) { create(:mentor, name: 'Inline Mentor') }
  let!(:kid) { create(:kid, name: 'Inline Kid', mentor: mentor) }

  background do
    log_in(create(:admin))
    visit kid_mentor_relations_path
    # a real page load resets window state, so the marker surviving proves the
    # value was saved in place
    page.execute_script('window.no_reload_marker = true')
  end

  def row_selects
    find('tr', text: 'Inline Kid').all('select')
  end

  scenario 'saves the exit kind of kid and mentor on change, without reloading the page' do
    kid_select, mentor_select = row_selects

    kid_select.select('macht 1 Jahr weiter')
    expect(page).to have_select(class: 'border-success', count: 1)
    mentor_select.select('Steigt aus')
    expect(page).to have_select(class: 'border-success', count: 2)

    expect(page.evaluate_script('window.no_reload_marker')).to be(true)
    expect(kid.reload.exit_kind).to eq('continue')
    expect(mentor.reload.exit_kind).to eq('exit')

    visit kid_mentor_relations_path
    kid_select, mentor_select = row_selects
    expect(kid_select.value).to eq('continue')
    expect(mentor_select.value).to eq('exit')
  end

  scenario 'asks for and saves an exit date when later is chosen' do
    kid_select = row_selects.first
    date_input = find("#kid_#{kid.id}_exit_at", visible: :all)
    expect(date_input).not_to be_visible

    kid_select.select('Alternatives Ausstiegsdatum')
    expect(date_input).to be_visible
    expect(page).to have_select(class: 'border-success')
    expect(kid.reload.exit_kind).to eq('later')

    date_input.set(Date.new(2026, 12, 24))
    expect(page).to have_field(type: 'date', class: 'border-success')
    expect(kid.reload.exit_at).to eq(Date.new(2026, 12, 24))

    visit kid_mentor_relations_path
    expect(find("#kid_#{kid.id}_exit_at").value).to eq('2026-12-24')
  end

  scenario 'clears the exit kind when the blank option is chosen' do
    kid.update!(exit_kind: 'exit')
    visit kid_mentor_relations_path

    row_selects.first.select('')
    expect(page).to have_select(class: 'border-success')
    expect(kid.reload.exit_kind).to be_nil
  end

  scenario 'puts the previous value back when saving fails' do
    kid.update!(exit_kind: 'exit')
    # make the save fail: without a name the kid is invalid
    kid.update_columns(name: '') # rubocop:disable Rails/SkipsModelValidations
    visit kid_mentor_relations_path

    kid_select = find('tr', text: kid.prename).first('select')
    kid_select.select('macht 1 Jahr weiter')

    expect(page).to have_select(class: 'border-danger')
    expect(kid_select.value).to eq('exit')
    expect(kid.reload.exit_kind).to eq('exit')
  end

  scenario 'does not show a redirect (e.g. to the login page) as saved' do
    # the session ends while the list is open: the PATCH is redirected to the login
    page.driver.browser.cookies.clear
    row_selects.first.select('macht 1 Jahr weiter')

    expect(page).to have_select(class: 'border-danger')
    expect(page).to have_no_select(class: 'border-success')
    expect(kid.reload.exit_kind).to be_nil
  end

  scenario 'renders the dropdowns without duplicate ids' do
    expect(page).to have_no_css('#kid_exit_kind', visible: :all)
    expect(page).to have_no_css('#mentor_exit_kind', visible: :all)
  end
end
