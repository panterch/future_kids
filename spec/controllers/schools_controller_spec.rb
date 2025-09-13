require 'spec_helper'

describe SchoolsController do
  before do
    sign_in @admin = create(:admin)
  end

  context 'new' do
    it 'renders' do
      get :new
      expect(response).to be_successful
    end
  end

  context 'create' do
    it 'redirects on success' do
      post :create, params: { school: { name: 'test school' } }
      expect(School.count).to eq(1)
      expect(response).to be_redirect
    end

    it 'renders again on failure' do
      post :create, params: { school: { name: '' } }
      expect(School.count).to eq(0)
      expect(response).to be_successful
    end
  end

  context 'index' do
    before do
      @school = create(:school)
    end

    it 'renders' do
      get :index
      expect(assigns(:schools)).to eq([@school])
      expect(response).to be_successful
    end
  end

  context 'edit' do
    before do
      @school = create(:school)
    end

    it 'renders' do
      get :edit, params: { id: @school.id }
      expect(assigns(:school)).to eq(@school)
      expect(response).to be_successful
    end
  end

  context 'update' do
    before do
      @school = create(:school)
    end

    it 'redirects on success' do
      put :create, params: { id: @school.id, school: { name: 'updated' } }
      expect(assigns(:school).name).to eq('updated')
      expect(response).to be_redirect
    end
  end
end
