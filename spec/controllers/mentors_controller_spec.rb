require 'spec/spec_helper'

describe MentorsController do

  before(:each) do
    @mentor = Factory(:mentor)
    sign_in @mentor
  end

  context 'index' do
  
    it 'should directly display the mentor when there is only one' do
      get :index
      response.should be_redirect
    end

  end 

  context 'show' do
    before(:each) do
      @journal = Factory(:journal, :mentor => @mentor, :held_at => '2011-01-01')
    end

    it 'assigns no journal entries when no available' do
      get :show, :id => @mentor
      assigns(:journals).should have(1).items # default entry
    end

    it 'assigns the precreated journal entries when no available' do
      get :show, :id => @mentor, :month => '1', :year => '2011'
      assigns(:journals).should include(@journal)
    end
  end


end
