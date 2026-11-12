# frozen_string_literal: true

require 'spec_helper'

# The only mail Devise sends here: German text (app/views/devise/mailer) and
# the sender of all other mails (config.mailer_sender in the devise initializer)
describe 'Password reset mail' do
  let(:mentor) { create(:mentor) }
  let(:mail) { ActionMailer::Base.deliveries.last }

  before do
    Site.load.update!(notifications_default_email: 'Future Kids <site@example.com>')
    post user_password_path, params: { user: { email: mentor.email } }
  end

  it 'goes to the user from the sender of the site settings' do
    expect(ActionMailer::Base.deliveries.size).to eq(1)
    expect(mail.to).to eq([mentor.email])
    expect(mail.from).to eq(['site@example.com'])
  end

  it 'is written in German and links to the form for the new password' do
    body = mail.body.decoded
    expect(mail.subject).to eq('Anleitung um Ihr Passwort zurückzusetzen')
    expect(body).to include('Guten Tag').and include('6 Stunden')
    expect(body).to include('/user/password/edit?reset_password_token=')
    expect(body).not_to include('Hello')
  end
end
