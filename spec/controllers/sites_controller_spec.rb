require 'spec_helper'

describe SitesController do


  context 'as a admin' do
    before(:each) do
      @admin = create(:admin, terms_of_use_accepted: true)
      @kid = create(:kid)
      sign_in @admin
    end

    it 'renders xlsx' do
      get :show, format: 'xlsx'
      expect(response).to be_successful
    end

  end

end
