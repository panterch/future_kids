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
        assigns(:admins).should have(3).items # 3 including the signed in admin
      end
    end
  end
end