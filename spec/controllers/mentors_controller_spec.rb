require 'spec_helper'

describe MentorsController do

  before(:each) do
    @mentor = Factory(:mentor)
    sign_in @mentor
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

  context 'update_schedules' do
    it 'creates schedule entries' do
      put :update_schedules, :id => @mentor.id, :mentor => {
        :schedules_attributes => [
        { :day => 1, :hour => 15, :minute => 0 },
        { :day => 2, :hour => 16, :minute => 30 }
      ] }
      @mentor.reload.schedules.count.should eq(2)
    end
  end


end
