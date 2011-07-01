require 'spec/spec_helper'

describe KidsController do

  before(:each) do
    @mentor = Factory(:mentor)
    @kid = Factory(:kid, :mentor => @mentor)
    sign_in @mentor
  end

  context 'index' do
  
    it 'should render index when many kids availbale' do
      @kid = Factory(:kid, :mentor => @mentor)
      get :index
      response.should be_successful
    end
    
    it 'should directly display the kid when there is only one' do
      get :index
      response.should be_redirect
    end

  end # end of as a mentor


end
