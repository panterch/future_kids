require 'spec_helper'

describe SchoolsController do
  before(:each) do
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
      post :create, school: { name: 'test school' }
      expect(School.count).to eq(1)
      expect(response).to be_redirect
    end
    it 'renders again on failure' do
      post :create, school: { name: '' }
      expect(School.count).to eq(0)
      expect(response).to be_success
    end
  end

  context 'index' do
    before(:each) do
      @school = create(:school)
    end

    it 'renders' do
      get :index
      expect(assigns(:schools)).to eq([@school])
      expect(response).to be_successful
    end
  end

  context 'edit' do
    before(:each) do
      @school = create(:school)
    end

    it 'renders' do
      get :edit, id: @school.id
      expect(assigns(:school)).to eq(@school)
      expect(response).to be_successful
    end
  end

  context 'update' do
    before(:each) do
      @school = create(:school)
    end

    it 'redirects on success' do
      put :create, id: @school.id, school: { name: 'updated' }
      expect(assigns(:school).name).to eq('updated')
      expect(response).to be_redirect
    end
  end
end
