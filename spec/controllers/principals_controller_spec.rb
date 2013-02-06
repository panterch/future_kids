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

      it 'cant edit the own record' do
        expect { get :edit, :id => @principal.id }.to raise_error(CanCan::AccessDenied)
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

  end


end
