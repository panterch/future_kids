require 'spec_helper'

describe RemindersController do

  before(:each) do
    @admin = create(:admin)
    @reminder = create(:reminder)
    sign_in @admin
  end

  context 'index' do

    it 'should index' do
      get :index
      response.should be_successful
    end

    it 'should not display acknolodges reminders' do
      create(:reminder, :acknowledged_at => Time.now)
      get :index
      assigns(:reminders).should eq([@reminder])
    end

  end # end of as a mentor


end
