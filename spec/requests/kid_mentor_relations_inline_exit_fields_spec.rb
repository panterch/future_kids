# frozen_string_literal: true

require 'requests/acceptance_helper'

# Covers the inline "Austritt" (exit term) and, for kids only, "Grund für
# Ausstieg" dropdowns of the Bewegungen list, saved in place the same way as
# the exit kind dropdown (see kid_mentor_relations_inline_exit_kind_spec.rb).
feature 'Bewegungen inline exit fields', :js do
  let!(:mentor) { create(:mentor, name: 'Inline Mentor') }
  let!(:kid) { create(:kid, name: 'Inline Kid', mentor: mentor) }

  background do
    log_in(create(:admin))
    visit kid_mentor_relations_path
  end

  def row
    find('tr', text: 'Inline Kid')
  end

  scenario 'offers an exit term for kid and mentor, and an exit reason for the kid only' do
    expect(row).to have_select('kid[exit]')
    expect(row).to have_select('kid[exit_reason]')
    expect(row).to have_select('mentor[exit]')
    expect(row).to have_no_select('mentor[exit_reason]')
  end

  scenario 'saves the exit term and exit reason of the kid on change' do
    exit_select = row.find('select[name="kid[exit]"]')
    first_term = exit_select.all('option', visible: :all).map(&:text).compact_blank.first
    exit_select.select(first_term)
    expect(page).to have_select(class: 'border-success', count: 1)
    row.find('select[name="kid[exit_reason]"]').select('Wegzug')
    expect(page).to have_select('kid[exit_reason]', class: 'border-success')

    expect(kid.reload).to have_attributes(exit: first_term, exit_reason: 'Wegzug')
  end

  scenario 'saves the exit term of the mentor on change' do
    exit_select = row.find('select[name="mentor[exit]"]')
    first_term = exit_select.all('option', visible: :all).map(&:text).compact_blank.first
    exit_select.select(first_term)
    expect(page).to have_select(class: 'border-success', count: 1)

    expect(mentor.reload.exit).to eq(first_term)
  end

  scenario 'still shows an exit term outside the configured years, instead of a blank dropdown' do
    kid.update!(exit: '2001 Frühling')
    visit kid_mentor_relations_path

    expect(row.find('select[name="kid[exit]"]').value).to eq('2001 Frühling')
  end
end
