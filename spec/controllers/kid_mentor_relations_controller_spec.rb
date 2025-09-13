require 'spec_helper'

describe KidMentorRelationsController do
  context 'as a admin' do
    before do
      @admin = create(:admin)
      @mentor = create(:mentor)
      create(:kid, mentor: @mentor)
      sign_in @admin
    end

    context 'index' do
      it 'displays index' do
        create(:kid)
        get :index
        expect(assigns(:kid_mentor_relations).length).to eq(2)
      end

      it 'filters kids when criteria given' do
        create(:kid, exit_kind: 'exit', mentor: @mentor)
        get :index, params: { kid_mentor_relation: { kid_exit_kind: 'exit' } }
        expect(assigns(:kid_mentor_relations).length).to eq(1)
      end

      it 'renders xlsx' do
        create(:kid)
        create(:kid, exit_kind: 'exit', mentor: @mentor)
        get :index, format: 'xlsx'
        expect(response).to be_successful
      end
    end
  end # end of as an admin

  context 'as a mentor' do
    before do
      @mentor = create(:mentor)
      sign_in @mentor
    end

    context 'index' do
      it 'denies access' do
        expect { get :index }.to raise_error(SecurityError)
      end
    end
  end # end of as a mentor
end
