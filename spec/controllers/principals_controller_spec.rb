require 'spec/spec_helper'

describe PrincipalsController do

  describe 'as a principal' do
    before(:each) do
      @principal = Factory(:principal)
      sign_in @principal
    end

    context 'show' do

      it 'can show the own record' do
        get :show, :id => @principal.id
        response.should be_successful
      end

      it 'can edit the own record' do
        get :edit, :id => @principal.id
        response.should be_successful
      end

      it 'cant edit the other record' do
        expect do
          get :edit, :id => Factory(:principal).id
        end.to raise_error(CanCan::AccessDenied)
      end

      it 'can update its own record' do
        put :update, :id => @principal.id, :principal => {
          :name => 'changed' }
        response.should be_redirect
        @principal.reload.name.should eq('changed')
      end

      it 'cannot update its own school or inactivity' do
        @original_school = @principal.school
        @school = Factory(:school)
        expect do
          put :update, :id => @principal.id, :principal => {
            :school_id => @school.id  }
        end.to raise_error(SecurityError)
        @principal.reload.school.should eq(@original_school)
      end

    end
  end


  describe 'as an admin' do
    before(:each) do
      @admin = Factory(:admin)
      @principal = Factory(:principal)
      sign_in @admin
    end

    it 'new' do
      get :new
      response.should be_successful
    end

    it 'show' do
      get :show, :id => @principal.id
      response.should be_successful
    end

    it 'edit' do
      get :edit, :id => @principal.id
      response.should be_successful
    end

    it 'can update the principals school' do
      @school = Factory(:school)
      put :update, :id => @principal.id, :principal => {
        :school_id => @school.id  }
      response.should be_redirect
      @principal.reload.school.should eq(@school)
    end


  end


end
