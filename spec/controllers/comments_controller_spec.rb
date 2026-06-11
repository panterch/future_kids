# frozen_string_literal: true

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
      expect_access_denied { get :new, params: { kid_id: @foreign.kid.id, journal_id: @foreign.id } }
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

    it 'records the current user as creator' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                              comment: attributes_for(:comment) }
      expect(assigns(:comment).created_by).to eq(@mentor)
    end

    it 'ignores a creator submitted via parameters' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                              comment: attributes_for(:comment).merge(created_by_id: @coach.id) }
      expect(assigns(:comment).created_by).to eq(@mentor)
    end

    it 'renders the edit template' do
      @comment = create(:comment, journal: @journal, created_by: @mentor)
      get :edit, params: { kid_id: @kid.id, journal_id: @journal.id, id: @comment.id }
      expect(response).to be_successful
    end

    it 'is not able to update other comments' do
      @comment = create(:comment, journal: @journal, created_by: @coach)
      expect_access_denied do
        put :update, params: { kid_id: @kid.id, journal_id: @journal.id,
                               id: @comment.id }
      end
    end

    it 'updates a comment and redirects to the journal anchor' do
      @comment = create(:comment, journal: @journal, created_by: @mentor)
      put :update, params: { kid_id: @kid.id, journal_id: @journal.id,
                             id: @comment.id, comment: { body: 'Updated body' } }
      expect(response).to redirect_to(kid_url(@kid, anchor: "journal_#{@journal.id}"))
    end

    it 'does not update a comment with invalid params' do
      @comment = create(:comment, journal: @journal, created_by: @mentor)
      put :update, params: { kid_id: @kid.id, journal_id: @journal.id,
                             id: @comment.id, comment: { body: '' } }
      expect(response).to be_successful
    end

    it 'sends a mail on comment creation' do
      expect do
        post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                                comment: attributes_for(:comment) }
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end
  end

  context 'as the kids teacher' do
    before do
      @teacher = create(:teacher)
      @kid.update!(teacher: @teacher)
      sign_in @teacher
    end

    # all users that can read the journal may comment on it
    it 'creates a journal comment entry' do
      post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                              comment: attributes_for(:comment) }
      expect(response).to be_redirect
      expect(assigns(:comment).created_by).to eq(@teacher)
    end
  end

  context 'as a mentor without access to the journal' do
    before do
      sign_in create(:mentor)
    end

    it 'does not allow creating comments' do
      expect_access_denied do
        post :create, params: { kid_id: @kid.id, journal_id: @journal.id,
                                comment: attributes_for(:comment) }
      end
    end
  end
end
