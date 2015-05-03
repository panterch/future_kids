require 'spec_helper'

describe PrincipalsController do
  describe 'as a principal' do
    before(:each) do
      @principal = create(:principal)
      sign_in @principal
    end

    context 'show' do
      it 'can show the own record' do
        get :show, id: @principal.id
        expect(response).to be_successful
      end

      it 'can edit the own record' do
        get :edit, id: @principal.id
        expect(response).to be_successful
      end

      it 'cant edit the other record' do
        expect do
          get :edit, id: create(:principal).id
        end.to raise_error(CanCan::AccessDenied)
      end

      it 'can update its own record' do
        put :update, id: @principal.id, principal: {
          name: 'changed' }
        expect(response).to be_redirect
        expect(@principal.reload.name).to eq('changed')
      end

      it 'cannot update its own school or inactivity' do
        @original_school = @principal.school
        @school = create(:school)
        expect do
          put :update, id: @principal.id, principal: {
            school_id: @school.id  }
        end.to raise_error(SecurityError)
        expect(@principal.reload.school).to eq(@original_school)
      end
    end
  end

  describe 'as an admin' do
    before(:each) do
      @admin = create(:admin)
      @principal = create(:principal)
      sign_in @admin
    end

    it 'excludes inactive on index' do
      create(:principal, inactive: true)
      get :index
      expect(assigns(:principals).size).to eq(1)
    end

    it 'new' do
      get :new
      expect(response).to be_successful
    end

    it 'show' do
      get :show, id: @principal.id
      expect(response).to be_successful
    end

    it 'edit' do
      get :edit, id: @principal.id
      expect(response).to be_successful
    end

    it 'can update the principals school' do
      @school = create(:school)
      put :update, id: @principal.id, principal: {
        school_id: @school.id  }
      expect(response).to be_redirect
      expect(@principal.reload.school).to eq(@school)
    end
  end
end
