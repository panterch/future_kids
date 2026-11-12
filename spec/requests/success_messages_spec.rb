# frozen_string_literal: true

require 'spec_helper'

# Every form confirms that it saved or deleted: the responder sets the notice
# after respond_with (flash.actions in the locale file), also where a
# controller passes its own redirect target.
describe 'Success messages' do
  let(:admin) { create(:admin) }
  let(:mentor) { create(:mentor) }
  let(:kid) { create(:kid, mentor: mentor) }
  let(:journal) { create(:journal, kid: kid, mentor: mentor) }

  # follows the redirect, so the sign in notice is shown and gone: the
  # responder keeps a notice that is already there
  def sign_in_as(user)
    post user_session_path, params: { user: { email: user.email, password: user.password } }
    follow_redirect!
  end

  context 'redirecting to the record' do
    it 'confirms an update and shows it on the next page' do
      sign_in_as(admin)
      patch kid_path(kid), params: { kid: { name: 'Neu' } }
      expect(flash[:notice]).to eq('Gespeichert.')
      follow_redirect!
      expect(response.body).to include('Gespeichert.')
    end

    it 'confirms a created journal without naming the kid it responds with' do
      sign_in_as(mentor)
      post kid_journals_path(kid), params: { journal: { held_at: '2026-11-02', start_at: '13:00', end_at: '14:00',
                                                        meeting_type: 'physical' } }
      expect(flash[:notice]).to eq('Gespeichert.')
    end

    it 'confirms a deletion' do
      sign_in_as(admin)
      delete kid_journal_path(kid, journal)
      expect(flash[:notice]).to eq('Gelöscht.')
    end
  end

  context 'redirecting somewhere else' do
    it 'confirms a created school on the list' do
      sign_in_as(admin)
      post schools_path, params: { school: { name: 'Neue Schule' } }
      expect(response).to redirect_to(schools_path)
      expect(flash[:notice]).to eq('Gespeichert.')
    end

    it 'shows the form again without a notice when the school is invalid' do
      sign_in_as(admin)
      post schools_path, params: { school: { name: '' } }
      expect(response).to have_http_status(:ok)
      expect(flash[:notice]).to be_nil
    end

    it 'confirms an uploaded document on the list' do
      sign_in_as(admin)
      file = fixture_file_upload('gespraechsdoku.pdf', 'application/pdf')
      post documents_path, params: { document: { title: 'Neu', attachment: file } }
      expect(response).to redirect_to(documents_path)
      expect(flash[:notice]).to eq('Gespeichert.')
    end

    it 'confirms a created comment' do
      sign_in_as(mentor)
      post kid_journal_comments_path(kid, journal), params: { comment: { by: 'Mentor', body: 'Kommentar' } }
      expect(flash[:notice]).to eq('Gespeichert.')
    end

    it 'confirms the saved site settings' do
      sign_in_as(admin)
      patch site_path, params: { site: { title: 'Future Kids' } }
      expect(flash[:notice]).to eq('Gespeichert.')
    end

    it 'confirms a document deleted from the tree, which reloads the page afterwards' do
      file = fixture_file_upload('gespraechsdoku.pdf', 'application/pdf')
      document = build(:document).attachment.attach(file).record.tap(&:save!)
      sign_in_as(admin)
      delete document_path(document), xhr: true
      expect(response).to have_http_status(:no_content)
      expect(flash[:notice]).to eq('Gelöscht.')
    end
  end
end
