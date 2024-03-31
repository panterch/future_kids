require 'spec_helper'

describe CommentsController do
  before(:each) do
    @mentor = create(:mentor)
    @coach = create(:admin)
    @kid = create(:kid, mentor: @mentor, admin: @coach)
    @journal = create(:journal, kid: @kid, mentor: @mentor)
  end

  context 'as a mentor' do
    before(:each) do
      sign_in @mentor
    end

    it 'should render the new template' do
      get :new, params: { kid_id: @kid.id, journal_id: @journal.id }
      expect(response).to be_successful
    end

    it 'should not render the new template for foreign journal entries' do
      @foreign = create(:journal)
      expect { get :new, params: { kid_id: @foreign.kid.id, journal_id: @foreign.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'should not create an invalid journal entry' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id }
      expect(response).to be_successful
    end

    it 'should create a journal comment entry' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                              comment: attributes_for(:comment) }
      expect(response).to be_redirect
    end

    it 'should not be able to update other comments' do
      @comment = create(:comment, journal: @journal, created_by: @coach )
      expect {
        put :update, params: { kid_id: @kid.id, journal_id: @journal.id,
                               id: @comment.id }
      }.to raise_error CanCan::AccessDenied
    end

    it 'should send a mail on comment creation' do
      expect { post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                    comment: attributes_for(:comment) }
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end
end
