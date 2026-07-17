# frozen_string_literal: true

require 'spec_helper'

describe SitesController do
  context 'as a admin' do
    before do
      @admin = create(:admin)
      @kid = create(:kid)
      sign_in @admin
    end

    it 'renders xlsx' do
      get :show, format: 'xlsx'
      expect(response).to be_successful
      expect(response.headers['Content-Disposition'])
        .to match(/filename="futurekids-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}\.xlsx"/)
    end

    context 'update' do
      it 'updates the ai api token when given' do
        put :update, params: { site: { ai_api_token: 'new-token' } }
        expect(Site.load.ai_api_token).to eq('new-token')
      end

      it 'keeps the existing ai api token when submitted blank' do
        Site.load.update!(ai_api_token: 'existing-token')
        put :update, params: { site: { ai_api_token: '', title: 'Future Kids' } }
        expect(Site.load.ai_api_token).to eq('existing-token')
        expect(Site.load.title).to eq('Future Kids')
      end
    end
  end
end
