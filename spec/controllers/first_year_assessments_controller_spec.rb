# frozen_string_literal: true

require 'spec_helper'

describe FirstYearAssessmentsController do
  before do
    @mentor = create(:mentor)
    @teacher = create(:teacher)
    @kid = create(:kid, mentor: @mentor, teacher: @teacher)
  end

  context 'as the kids mentor' do
    before do
      sign_in @mentor
    end

    it 'renders the new template' do
      get :new, params: { kid_id: @kid.id }
      expect(response).to be_successful
    end

    it 'creates a new entry' do
      post :create, params: valid_attributes
      expect(assigns(:first_year_assessment)).not_to be_new_record
    end

    it 'records the current user as creator' do
      post :create, params: valid_attributes
      expect(assigns(:first_year_assessment).created_by).to eq(@mentor)
    end

    it 'updates an entry' do
      assessment = create(:first_year_assessment, kid: @kid)
      put :update, params: valid_attributes.merge(id: assessment.id)
      expect(response).to be_redirect
      expect(assessment.reload.held_at).to eq(Date.parse('2018-10-01'))
    end

    it 'is not able to destroy an entry' do
      assessment = create(:first_year_assessment, kid: @kid)
      expect do
        delete :destroy, params: { kid_id: @kid.id, id: assessment.id }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'as the kids secondary mentor' do
    before do
      @secondary_mentor = create(:mentor)
      @kid.update!(secondary_mentor: @secondary_mentor, secondary_active: true)
      sign_in @secondary_mentor
    end

    it 'creates a new entry' do
      post :create, params: valid_attributes
      expect(assigns(:first_year_assessment)).not_to be_new_record
    end

    it 'denies creation once the secondary assignment is deactivated' do
      @kid.update!(secondary_active: false)
      expect { post :create, params: valid_attributes }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'as a foreign mentor' do
    before do
      sign_in create(:mentor)
    end

    it 'denies access to new' do
      expect { get :new, params: { kid_id: @kid.id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'denies creation' do
      expect { post :create, params: valid_attributes }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'as the kids teacher' do
    before do
      sign_in @teacher
    end

    it 'denies access to new' do
      expect { get :new, params: { kid_id: @kid.id } }.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'as an admin' do
    before do
      sign_in create(:admin)
    end

    it 'destroys an entry' do
      assessment = create(:first_year_assessment, kid: @kid)
      delete :destroy, params: { kid_id: @kid.id, id: assessment.id }
      expect(FirstYearAssessment).not_to exist(assessment.id)
    end
  end

  def valid_attributes
    { kid_id: @kid.id,
      first_year_assessment: { held_at: '2018-10-01',
                               teacher_id: @teacher.id,
                               mentor_id: @mentor.id } }
  end
end
