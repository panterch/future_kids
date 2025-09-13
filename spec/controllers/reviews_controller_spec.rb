require 'spec_helper'

describe ReviewsController do
  before do
    @mentor = create(:mentor)
    @kid = create(:kid, mentor: @mentor)
  end

  context 'as a mentor' do
    before do
      sign_in @mentor
    end

    it 'renders the new template' do
      get :new, params: { kid_id: @kid.id }
      expect(response).to be_successful
    end

    it 'denies access for foreign kids' do
      expect { get :new, params: { kid_id: create(:kid).id } }.to raise_error(CanCan::AccessDenied)
    end

    it 'creates a new entry' do
      post :create, params: valid_attributes
      expect(assigns(:review)).not_to be_new_record
    end

    it 'is not able to create entries for other kids' do
      attrs = valid_attributes
      attrs[:kid_id] = create(:kid).id
      expect { post :create, params: attrs }.to raise_error(CanCan::AccessDenied)
    end

    # kid_id is submitted as url parameter - it should not be taintable
    # via the attributes hash for review
    it 'is not able to taint kid_id via review parameters' do
      attrs = valid_attributes
      attrs[:review][:kid_id] = create(:kid).id
      post :create, params: attrs
      expect(assigns(:review).kid).to eq(@kid)
    end

    it 'redirects on show' do
      get :show, params: { kid_id: @kid.id, id: create(:review, kid: @kid) }
      expect(response).to be_redirect
    end

    it 'redirects on index' do
      get :index, params: { kid_id: @kid.id }
      expect(response).to be_redirect
    end
  end # end of as a mentor

  context 'as an admin' do
    before do
      sign_in create(:admin)
    end

    it 'records phone coaching' do
      attrs = valid_attributes
      attrs[:review][:reason] = 'Telefoncoaching'
      post :create, params: attrs

      expect(response).to be_redirect
      expect(@kid.reload.coached_at).not_to be_nil
      expect(@kid.coached_at).to eq(attrs[:review][:held_at])
      expect(@kid.checked_at).to eq(attrs[:review][:held_at])
    end
  end

  # valid attributes to create a journal
  # this uses strings for time and date fields, since this is what we
  # want to submit via the jquery widgets
  def valid_attributes
    attrs = {}
    attrs[:review] = attributes_for(:review)
    attrs[:kid_id] = @kid.id
    attrs
  end
end
