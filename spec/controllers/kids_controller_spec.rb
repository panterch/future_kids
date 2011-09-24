require 'spec/spec_helper'

describe KidsController do

  context 'as a mentor' do

    before(:each) do
      @mentor = Factory(:mentor)
      @kid = Factory(:kid, :mentor => @mentor)
      sign_in @mentor
    end

    context 'index' do
    
      it 'should directly display the kid when there is only one' do
        get :index
        response.should be_redirect
      end

      it 'should render index when many kids availbale' do
        Factory(:kid, :mentor => @mentor)
        get :index
        response.should be_successful
      end
      
    end

    context 'schedules' do

      it 'should not allow displaying the kids schedule' do
        expect { get :edit_schedules, :id => @kid }.to
          raise_error(CanCan::AccessDenied)
      end

      it 'should not allow updating the kids schedule' do
        expect { post :update_schedules, :id => @kid }.to
          raise_error(CanCan::AccessDenied)
      end

    end

  end # end of as a mentor

  context 'as a admin' do

    before(:each) do
      @admin = Factory(:admin)
      @kid = Factory(:kid)
      sign_in @admin
    end

    context 'edit_schedules' do

      it 'should display the kids schedule' do
        get :edit_schedules, :id => @kid
        response.should be_successful
      end

      it 'should assign mentors' do
        @mentor = Factory(:mentor)
        get :edit_schedules, :id => @kid, :mentor_ids => [ @mentor.id ]
        assigns(:mentor_ids).should eq([@mentor.id.to_s])
        assigns(:mentor_groups)["none"].should eq([@mentor])
      end

    end

    context 'update_schedules' do

      it 'should create a new schedule' do
        post :update_schedules, :id => @kid, :kid =>
          { :schedules_attributes => [ FactoryGirl.attributes_for(:schedule)] }
        response.should be_redirect
        @kid.schedules.count.should eq(1)
      end

    end

  end # end of as an admin

end
