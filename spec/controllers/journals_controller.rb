require 'spec/spec_helper'

describe JournalsController do

  describe 'creating entries' do
    before(:each) do
      @admin = Factory(:admin)
      @kid = Factory(:kid)
      @mentor = Factory(:mentor)
      sign_in @admin
    end
    
    it 'should render the new template' do
      get :new
      response.should be_successful
      response.should render_template(:new)
    end

    it 'should create a new entry' do
      post :create, :journal => valid_attributes
      assigns(:journal).should_not be_new_record
    end

    # valid attributes to create a journal
    # this uses strings for time and date fields, since this is what we
    # want to submit via the jquery widgets
    def valid_attributes
      Factory.attributes_for(:journal, :title => 'journal spec',
        :mentor_id => @mentor.id,
        :kid_id    => @kid.id,
        :held_at   => '2011-05-30',
        :start_at  => '12:00',
        :end_at    => '12:30')
    end

  end
end
