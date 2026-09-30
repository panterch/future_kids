# frozen_string_literal: true

require 'requests/acceptance_helper'

RSpec.describe 'KidMentorRelations' do
  feature 'KidMentorRelations as Admin' do
    let(:mentor_no_exit) { create(:mentor, name: 'Mentor No') }
    let(:mentor_exit) { create(:mentor, exit_kind: 'exit', name: 'Mentor Later') }

    before do
      log_in(create(:admin))

      # create many combinations of kids and mentors exiting and not exiting
      # recognizable by their name
      create(:kid, name: 'Kid No / Mentor No', mentor: mentor_no_exit)
      create(:kid, name: 'Kid No / Mentor Exit', mentor: mentor_exit)
      create(:kid, name: 'Kid Exit / Mentor No', exit_kind: 'exit', mentor: mentor_no_exit)
      create(:kid, name: 'Kid Exit / Mentor Exit', exit_kind: 'exit', mentor: mentor_exit)

      visit kid_mentor_relations_path
    end

    describe 'filtering' do
      scenario 'should show all kids without filtering' do
        expect(page).to have_text('Kid No / Mentor No')
        expect(page).to have_text('Kid No / Mentor Exit')
        expect(page).to have_text('Kid Exit / Mentor No')
        expect(page).to have_text('Kid Exit / Mentor Exit')
      end

      scenario 'filters for kids exit kind' do
        choose_filter('Aktueller Stand Schüler*in', 'Steigt aus')
        expect(page).to have_no_text('Kid No / Mentor No')
        expect(page).to have_no_text('Kid No / Mentor Exit')
        expect(page).to have_text('Kid Exit / Mentor No')
        expect(page).to have_text('Kid Exit / Mentor Exit')
      end

      scenario 'filters for mentors exit kind' do
        choose_filter('Aktueller Stand Mentor*in', 'Steigt aus')
        expect(page).to have_no_text('Kid No / Mentor No')
        expect(page).to have_text('Kid No / Mentor Exit')
        expect(page).to have_no_text('Kid Exit / Mentor No')
        expect(page).to have_text('Kid Exit / Mentor Exit')
      end

      scenario 'filters for combined exit kind' do
        choose_filter('Aktueller Stand Schüler*in', 'Steigt aus')
        choose_filter('Aktueller Stand Mentor*in', 'Steigt aus')
        expect(page).to have_no_text('Kid No / Mentor No')
        expect(page).to have_no_text('Kid No / Mentor Exit')
        expect(page).to have_no_text('Kid Exit / Mentor No')
        expect(page).to have_text('Kid Exit / Mentor Exit')
      end
    end

    scenario 'inactivting a relation' do
      # only one of our setup relations is ready for inactivation
      click_button('Inaktiv setzen')
      # inactivation will remove all kids of the mentor with the exit
      # flag (he has two kids assigned)
      expect(page).to have_text('Kid No / Mentor No')
      expect(page).to have_text('Kid No / Mentor Exit')
      expect(page).to have_text('Kid Exit / Mentor No')
      expect(page).to have_no_text('Kid Exit / Mentor Exit')
    end

    scenario 'reseting all data' do
      within('#main table') { expect(page).to have_css('option[selected]', text: 'Steigt aus') }
      click_link('Alle zurücksetzen')
      within('#main table') { expect(page).to have_no_css('option[selected]', text: 'Steigt aus') }
    end

    scenario 'offers all exit kinds as dropdown' do
      within('#main table') do
        expect(page).to have_select(class: 'form-select',
                                    with_options: ['Steigt aus', 'Alternatives Ausstiegsdatum',
                                                   'macht ½ Jahr weiter', 'macht 1 Jahr weiter'])
      end
    end

    scenario 'shows the exit date input only for the exit kind later' do
      create(:kid, name: 'Kid Later', exit_kind: 'later', exit_at: Date.new(2026, 12, 24))
      visit kid_mentor_relations_path
      expect(page).to have_field(type: 'date', with: '2026-12-24', count: 1)
      expect(page).to have_css('input[type=date][min="2001-01-01"]', minimum: 1, visible: :all)
      expect(page).to have_field(type: 'date', class: 'd-none', visible: :all, minimum: 1)
    end
  end

  feature 'KidMentorRelations as Mentor' do
    scenario 'does not allow non admin access' do
      log_in(create(:mentor))
      expect { visit kid_mentor_relations_path }.to raise_error(SecurityError)
    end
  end
end
