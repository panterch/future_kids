# frozen_string_literal: true

require 'spec_helper'

describe TerminationAssessmentsController do
  before do
    @mentor = create(:mentor)
    @teacher = create(:teacher)
    @kid = create(:kid, mentor: @mentor, teacher: @teacher)
  end

  context 'as the kids teacher' do
    before do
      sign_in @teacher
    end

    it 'renders the new template' do
      get :new, params: { kid_id: @kid.id }
      expect(response).to be_successful
    end

    it 'creates a new entry' do
      post :create, params: valid_attributes
      expect(assigns(:termination_assessment)).not_to be_new_record
    end

    it 'records the current user as creator' do
      post :create, params: valid_attributes
      expect(assigns(:termination_assessment).created_by).to eq(@teacher)
    end

    it 'updates an entry' do
      assessment = create(:termination_assessment, kid: @kid)
      put :update, params: valid_attributes.merge(id: assessment.id)
      expect(response).to be_redirect
      expect(assessment.reload.held_at).to eq(Date.parse('2018-10-01'))
    end

    it 'is not able to destroy an entry' do
      assessment = create(:termination_assessment, kid: @kid)
      expect_access_denied do
        delete :destroy, params: { kid_id: @kid.id, id: assessment.id }
      end
    end
  end

  context 'as the kids third teacher' do
    before do
      @third_teacher = create(:teacher)
      @kid.update!(third_teacher: @third_teacher)
      sign_in @third_teacher
    end

    it 'creates a new entry' do
      post :create, params: valid_attributes
      expect(assigns(:termination_assessment)).not_to be_new_record
    end
  end

  context 'as a foreign teacher' do
    before do
      sign_in create(:teacher)
    end

    it 'denies access to new' do
      expect_access_denied { get :new, params: { kid_id: @kid.id } }
    end

    it 'denies creation' do
      expect_access_denied { post :create, params: valid_attributes }
    end
  end

  context 'as the kids mentor' do
    before do
      sign_in @mentor
    end

    it 'denies access to new' do
      expect_access_denied { get :new, params: { kid_id: @kid.id } }
    end
  end

  context 'as an admin' do
    before do
      sign_in create(:admin)
    end

    it 'destroys an entry' do
      assessment = create(:termination_assessment, kid: @kid)
      delete :destroy, params: { kid_id: @kid.id, id: assessment.id }
      expect(TerminationAssessment).not_to exist(assessment.id)
    end
  end

  def valid_attributes
    { kid_id: @kid.id,
      termination_assessment: { held_at: '2018-10-01',
                                teacher_id: @teacher.id } }
  end
end
