# frozen_string_literal: true

require 'spec_helper'

describe JournalSummariesController do
  let(:kid) { create(:kid) }

  before do
    Site.load.update!(ai_features_enabled: true)
    create(:journal, kid: kid)
    sign_in create(:admin)
  end

  context 'create' do
    it 'stores the generated summary and redirects to the kid' do
      allow_any_instance_of(JournalSummarizer).to receive(:call).and_return('Zusammenfassung')

      post :create, params: { kid_id: kid.id }

      expect(kid.reload.journal_summary).to eq('Zusammenfassung')
      expect(kid.journal_summary_generated_at).not_to be_nil
      expect(response).to redirect_to(kid_path(kid))
    end

    it 'shows an alert and does not update the kid when the summarizer fails' do
      allow_any_instance_of(JournalSummarizer).to receive(:call).and_raise(JournalSummarizer::Error, 'boom')

      post :create, params: { kid_id: kid.id }

      expect(kid.reload.journal_summary).to be_nil
      expect(response).to redirect_to(kid_path(kid))
      expect(flash[:alert]).to eq('boom')
    end
  end

  context 'when ai features are disabled' do
    before { Site.load.update!(ai_features_enabled: false) }

    it 'denies generating a summary' do
      expect_access_denied { post :create, params: { kid_id: kid.id } }
    end
  end

  context 'as a mentor with read access to the kid' do
    before do
      mentor = create(:mentor)
      kid.update!(mentor: mentor)
      sign_in mentor
    end

    it 'denies generating a summary' do
      expect_access_denied { post :create, params: { kid_id: kid.id } }
    end
  end
end
