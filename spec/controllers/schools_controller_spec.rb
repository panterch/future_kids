require 'spec/spec_helper'

describe SchoolsController do

  render_views

  before(:each) do
    sign_in @admin = Factory(:admin)
  end

  context 'new' do
    it 'renders' do
      get :new
      response.should be_successful
    end
  end

  context 'create' do
    it 'redirects on success' do
      post :create, :school => { :name => 'test school' }
      School.count.should eq(1)
      response.should be_redirect
    end
    it 'renders again on failure' do
      post :create, :school => { :name => '' }
      School.count.should eq(0)
      response.should be_success
    end
  end

  context 'index' do
    before(:each) do
      @school = Factory(:school)
    end

    it 'renders' do
      get :index
      assigns(:schools).should eq([@school])
      response.should be_successful
    end
  end

  context 'edit' do
    before(:each) do
      @school = Factory(:school)
    end

    it 'renders' do
      get :edit, :id => @school.id
      assigns(:school).should eq(@school)
      response.should be_successful
    end
  end

  context 'update' do
    before(:each) do
      @school = Factory(:school)
    end

    it 'redirects on success' do
      put :create, :id => @school.id, :school => { :name => 'updated' }
      assigns(:school).name.should eq('updated')
      response.should be_redirect
    end
  end

end
