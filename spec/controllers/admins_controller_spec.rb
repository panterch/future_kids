require 'spec_helper'

describe AdminsController do
  context 'as an admin' do
    before do
      @admin = create(:admin)
      sign_in @admin
    end

    context 'index' do
      it 'assigns two admins in the index' do
        2.times { create(:admin) }
        get :index
        expect(assigns(:admins).size).to eq(3) # 3 including the signed in admin
        expect(response).to be_successful
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
        get :show, params: { id: @admin.id }
        expect(response).to be_successful
        expect(response.body).to match(/#{@kid.name}/)
      end
    end

    context 'edit' do
      it 'renders' do
        get :show, params: { id: @admin.id }
        expect(response).to be_successful
      end
    end
  end

  context 'as a mentor' do
    before do
      @admin = create(:admin)
      @mentor = create(:mentor)
      sign_in @mentor
    end

    context 'show' do
      it 'is not allowed to display random mentors' do
        expect do
          get :show, params: { id: @admin.id }
        end.to raise_error CanCan::AccessDenied
      end

      it 'displays only basic information on coaches' do
        create(:kid, mentor: @mentor, admin: @admin)
        get :show, params: { id: @admin.id }
        expect(response).to be_successful
        expect(response.body).to match(/#{@admin.name}/)
        expect(response.body).not_to match(/Pendenzen/)
      end
    end
  end
end
