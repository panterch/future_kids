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
        select('Steigt aus', from: 'kid_mentor_relation_kid_exit_kind')
        click_button('Filter anwenden')
        expect(page).to have_no_text('Kid No / Mentor No')
        expect(page).to have_no_text('Kid No / Mentor Exit')
        expect(page).to have_text('Kid Exit / Mentor No')
        expect(page).to have_text('Kid Exit / Mentor Exit')
      end

      scenario 'filters for mentors exit kind' do
        select('Steigt aus', from: 'kid_mentor_relation_mentor_exit_kind')
        click_button('Filter anwenden')
        expect(page).to have_no_text('Kid No / Mentor No')
        expect(page).to have_text('Kid No / Mentor Exit')
        expect(page).to have_no_text('Kid Exit / Mentor No')
        expect(page).to have_text('Kid Exit / Mentor Exit')
      end

      scenario 'filters for combined exit kind' do
        select('Steigt aus', from: 'kid_mentor_relation_kid_exit_kind')
        select('Steigt aus', from: 'kid_mentor_relation_mentor_exit_kind')
        click_button('Filter anwenden')
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
      within('#main table') { expect(page).to have_text('Steigt aus') }
      click_link('Alle zurücksetzen')
      within('#main table') { expect(page).to have_no_text('Steigt aus') }
    end
  end

  feature 'KidMentorRelations as Mentor' do
    scenario 'does not allow non admin access' do
      log_in(create(:mentor))
      expect { visit kid_mentor_relations_path }.to raise_error(SecurityError)
    end
  end
end
