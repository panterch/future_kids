require 'spec_helper'

describe PrincipalsController do
  describe 'as a principal' do
    before do
      @principal = create(:principal)
      sign_in @principal
    end

    context 'show' do
      it 'can show the own record' do
        get :show, params: { id: @principal.id }
        expect(response).to be_successful
      end

      it 'can edit the own record' do
        get :edit, params: { id: @principal.id }
        expect(response).to be_successful
      end

      it 'cant edit the other record' do
        expect do
          get :edit, params: { id: create(:principal).id }
        end.to raise_error(CanCan::AccessDenied)
      end
    end

    context 'edit' do
      it 'can update its own record' do
        put :update, params: { id: @principal.id, principal: {
          name: 'changed'
        } }
        expect(response).to be_redirect
        expect(@principal.reload.name).to eq('changed')
      end

      it 'cannot update its own school or inactivity' do
        @original_school = @principal.schools.first
        @school = create(:school)
        expect do
          put :update, params: { id: @principal.id, principal: {
            school_ids: [@school.id, @original_school.id]
          } }
        end.to raise_error(SecurityError)
        expect(@principal.reload.schools).not_to include(@school)
      end
    end
  end

  describe 'as an admin' do
    before do
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
      get :show, params: { id: @principal.id }
      expect(response).to be_successful
    end

    it 'edit' do
      get :edit, params: { id: @principal.id }
      expect(response).to be_successful
    end

    it 'can update the principals school' do
      @school = create(:school)
      put :update, params: { id: @principal.id, principal: {
        school_ids: [@school.id]
      } }
      expect(response).to be_redirect
      expect(@principal.reload.schools).to include(@school)
    end
  end
end
