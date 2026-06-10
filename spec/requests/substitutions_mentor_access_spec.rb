# frozen_string_literal: true

require 'requests/acceptance_helper'

feature 'MENTOR::SHOW:SUBSTITUTION', '
  As a mentor
  I want not be able to show/modify substitutions

' do
  let!(:mentor) do
    create(:mentor, prename: 'Mentor', name: 'Mentor', sex: 'm')
  end

  background do
    expect(User.first.valid_password?(mentor.password)).to be(true)
    log_in(mentor)
  end

  scenario 'mentor should not be able to show substitution' do
    expect { visit substitutions_path }.to raise_error(CanCan::AccessDenied)
  end

  scenario 'mentor should not be able to see substitution-header-link' do
    expect(page).to have_no_text('Ersatz')
  end
end
