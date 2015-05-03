require 'spec_helper'

describe AdminsController do
  context 'as an admin' do
    before(:each) do
      @admin = create(:admin)
      sign_in @admin
    end

    context 'index' do
      it 'assigns two admins in the index' do
        2.times { create(:admin) }
        get :index
        expect(assigns(:admins).size).to eq(3) # 3 including the signed in admin
        expect(response).to be_success
      end

      it 'excludes inactive admins' do
        create(:admin, inactive: true)
        get :index
        expect(assigns(:admins).size).to eq(1)
      end
    end

    context 'show' do
      it 'displays relation log' do
        @kid = create(:kid, admin: @admin)
        get :show, id: @admin.id
        expect(response).to be_success
        expect(response.body).to match /#{@kid.name}/
      end
    end

    context 'edit' do
      it 'renders' do
        get :show, id: @admin.id
        expect(response).to be_success
      end
    end
  end
end
