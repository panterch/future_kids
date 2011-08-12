require 'spec/spec_helper'

describe SchedulesController do

  context 'as an admin' do

    before(:each) do
      @admin = Factory(:admin)
      @mentor = Factory(:mentor)
      @kid = Factory(:kid)
      sign_in @admin
    end

    context 'index' do
      it 'should index on mentor' do
        get :index, :mentor_id => @mentor.id
        response.should be_successful
        assigns(:person).should eq(@mentor)
      end
      it 'should index on kid' do
        get :index, :kid_id => @kid.id
        assigns(:person).should eq(@kid)
      end
      it 'should assign the weeks schedule' do
        get :index, :kid_id => @kid.id
        assigns(:week).size.should eq(5)
      end
      it 'should use the already created entry in week' do
        # create a schedule entry for the mentor on the first day of the week as
        # the first possible time (week[0][0])
        Factory(:schedule, :person => @mentor, :day => 1, :hour => 13, :minute => 0)
        get :index, :mentor_id => @mentor.id
        assigns(:week)[0][0].should_not be_new_record
      end
      it 'should mark mentors days' do
        # create a schedule entry for the mentor on the first day of the week as
        # the first possible time (week[0][0])
        Factory(:schedule, :person => @mentor, :day => 1, :hour => 13, :minute => 0)
        get :index, :kid_id => @kid.id, :mentor_ids => [ @mentor.id ]
        assigns(:week)[0][0].mentor_tags.size.should eq(1)
        assigns(:week)[0][0].mentor_tags[0].should eq(@mentor.display_name)
      end
    end

  end

  it 'should not allow access as mentor' do
    @mentor = Factory(:mentor)
    sign_in @mentor
    expect { get :index }.to raise_error(SecurityError)
  end

end
