# frozen_string_literal: true

require 'spec_helper'

# paranoid mode of Devise: the answer must not tell who has an account
describe 'Password reset form answer' do
  let(:mentor) { create(:mentor) }

  def flash_after_reset_for(email)
    post user_password_path, params: { user: { email: email } }
    [response.status, response.location, flash[:notice], flash[:alert]]
  end

  it 'is the same for a known and an unknown address' do
    known = flash_after_reset_for(mentor.email)
    unknown = flash_after_reset_for('nobody@example.com')
    expect(unknown).to eq(known)
    expect(known[2]).to eq(I18n.t('devise.passwords.send_paranoid_instructions'))
  end

  it 'sends no mail for an unknown address' do
    expect { flash_after_reset_for('nobody@example.com') }.not_to(change { ActionMailer::Base.deliveries.size })
  end
end
