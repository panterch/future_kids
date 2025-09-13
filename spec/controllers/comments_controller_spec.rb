require 'spec_helper'

describe CommentsController do
  before do
    @mentor = create(:mentor)
    @coach = create(:admin)
    @kid = create(:kid, mentor: @mentor, admin: @coach)
    @journal = create(:journal, kid: @kid, mentor: @mentor)
  end

  context 'as a mentor' do
    before do
      sign_in @mentor
    end

    it 'renders the new template' do
      get :new, params: { kid_id: @kid.id, journal_id: @journal.id }
      expect(response).to be_successful
    end

    it 'does not render the new template for foreign journal entries' do
      @foreign = create(:journal)
      expect { get :new, params: { kid_id: @foreign.kid.id, journal_id: @foreign.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'does not create an invalid journal entry' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id }
      expect(response).to be_successful
    end

    it 'creates a journal comment entry' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                              comment: attributes_for(:comment) }
      expect(response).to be_redirect
    end

    it 'is not able to update other comments' do
      @comment = create(:comment, journal: @journal, created_by: @coach)
      expect do
        put :update, params: { kid_id: @kid.id, journal_id: @journal.id,
                               id: @comment.id }
      end.to raise_error CanCan::AccessDenied
    end

    it 'sends a mail on comment creation' do
      expect do
        post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                                comment: attributes_for(:comment) }
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
