require 'spec_helper'

describe TeachersController do

  context 'as an admin' do
    before(:each) do
      @admin = create(:admin)
      sign_in @admin
    end

    context 'index' do
      it 'assigns two teachers in the index' do
        2.times { create(:teacher) }
        get :index
        expect(assigns(:teachers).size).to eq(2)
      end
      it 'excludes inactive teachers by default' do
        create(:teacher, inactive: true)
        get :index
        expect(assigns(:teachers).size).to eq(0)
      end
      it 'filters for inactive teacher' do
        create(:teacher, inactive: true)
        get :index, inactive: '1'
        expect(assigns(:teachers).size).to eq(0)
      end
    end

    context 'show' do
      it 'renders' do
        @teacher = create(:teacher)
        get :show, id: @teacher.id
        expect(response).to be_success
      end
    end

    context 'edit' do
      it 'renders' do
        @teacher = create(:teacher)
        get :edit, id: @teacher.id
        expect(response).to be_success
      end
    end


  end

end
