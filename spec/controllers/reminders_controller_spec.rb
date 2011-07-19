require 'spec/spec_helper'

describe RemindersController do

  before(:each) do
    @admin = Factory(:admin)
    @reminder = Factory(:reminder)
    sign_in @admin
  end

  context 'index' do
  
    it 'should index' do
      get :index
      response.should be_successful
    end
    
    it 'should not display acknolodges reminders' do
      Factory(:reminder, :acknowledged_at => Time.now)
      get :index
      assigns(:reminders).should eq([@reminder])
    end

  end # end of as a mentor


end
