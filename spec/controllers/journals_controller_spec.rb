require 'spec/spec_helper'

describe JournalsController do

  before(:each) do
    @mentor = Factory(:mentor)
    @kid = Factory(:kid, :mentor => @mentor)
  end

  context 'as an admin' do
    before(:each) do
      @admin = Factory(:admin)
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
  end # end of 'as an admin'

  context 'as a mentor' do
    before(:each) do
      sign_in @mentor
    end
  
    it 'should render the new template' do
      get :new, :kid_id => @kid.id
      response.should be_successful
    end

    it 'should deny access for foreign kids' do
      expect { get :new, :kid_id => Factory(:kid).id }.to
        raise_error(CanCan::AccessDenied)
    end

    it 'should create a new entry' do
      post :create, :journal => valid_attributes
      assigns(:journal).should_not be_new_record
    end

    it 'should not be able to create entries for other mentors' do
      attrs = valid_attributes
      attrs[:mentor_id] = Factory(:mentor).id
      post :create, :journal => attrs
      assigns(:journal).mentor.should eq(@mentor)
    end

    it 'should not be able to create entries for other kids' do
      attrs = valid_attributes
      attrs[:kid_id] = Factory(:kid).id
      expect { post :create, :journal => attrs }.to
        raise_error(CanCan::AccessDenied)
    end
  end # end of as a mentor

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
