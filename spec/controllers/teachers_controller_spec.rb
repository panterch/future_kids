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
        assigns(:teachers).should have(2).items
      end
    end
  end

end
