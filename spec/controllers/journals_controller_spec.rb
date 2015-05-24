require 'spec_helper'

describe JournalsController do
  let(:admin) { create(:admin) }
  let(:mentor) { create(:mentor) }
  let(:kid) { create(:kid, mentor: mentor) }
  let(:journal) { create(:journal, kid: kid, mentor: mentor) }
  let(:secondary_kid) do
    create(:kid, secondary_mentor: mentor,
                 secondary_active: true)
  end

  context 'as an admin' do
    before(:each) do
      sign_in admin
    end

    it 'should render the new template' do
      get :new, kid_id: kid.id
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end

    it 'should render assign only selectable mentors' do
      foreign_mentor = create(:mentor)
      get :new, kid_id: kid.id
      expect(assigns(:mentors)).to eq([mentor])
    end

    it 'should not access new when no mentors available' do
      Mentor.destroy_all
      get :new, kid_id: create(:kid).id
      expect(response).to be_redirect
    end

    it 'should create a new entry posting valid attributes' do
      post :create, valid_attributes
      expect(assigns(:journal)).not_to be_new_record
    end

    it 'should parse ch date formatted strings for held_at' do
      attrs = valid_attributes
      attrs[:journal][:held_at] = '31.12.2010'
      post :create, attrs
      expect(assigns(:journal).held_at).to eq(Date.parse('2010-12-31'))
    end

    it 'renders new' do
      get :new, kid_id: kid.id
      expect(response).to be_successful
      expect(response).to render_template(:new)
    end

    it 'renders edit' do
      get :edit, kid_id: kid.id, id: journal.id
      expect(response).to be_successful
      expect(response).to render_template(:edit)
    end

    it 'redirects on show' do
      get :show, kid_id: kid.id, id: journal.id
      expect(response).to be_redirect
    end

    it 'redirects on index' do
      get :index, kid_id: kid.id
      expect(response).to be_redirect
    end

    it 'updates' do
      attrs = valid_attributes
      attrs[:id] = journal.id
      attrs[:journal][:goal] = 'updated goal'
      put :update, attrs
      expect(response).to be_redirect
      expect(journal.reload.goal).to eq('updated goal')
    end

    it 'destroys' do
      delete :destroy, kid_id: kid.id, id: journal.id
      expect(response).to be_redirect
      expect(Journal.count).to eq(0)
    end
  end # end of 'as an admin'

  context 'as a mentor' do
    before(:each) do
      sign_in mentor
    end

    it 'should render the new template' do
      get :new, kid_id: kid.id
      expect(response).to be_successful
    end

    it 'should render the new template for secondary kids' do
      get :new, kid_id: secondary_kid.id
      expect(response).to be_successful
    end

    it 'should not render the new template for inactive secondary kids' do
      inactive_kid = create(:kid, secondary_mentor: mentor,
                                  secondary_active: false)
      expect { get :new, kid_id: inactive_kid.id }.to raise_error(CanCan::AccessDenied)
    end

    it 'should not assign mentors for selectbox' do
      get :new, kid_id: kid.id
      expect(assigns(:mentors)).to be_nil
    end

    it 'should deny access for foreign kids' do
      expect { get :new, kid_id: create(:kid).id }.to raise_error(CanCan::AccessDenied)
    end

    it 'should create a new entry' do
      post :create, valid_attributes
      expect(assigns(:journal)).not_to be_new_record
    end

    it 'should not be able to create entries for other mentors' do
      attrs = valid_attributes
      attrs[:journal][:mentor_id] = create(:mentor).id
      post :create, attrs
      expect(assigns(:journal).mentor).to eq(mentor)
    end

    it 'should not be able to create entries for other kids' do
      attrs = valid_attributes
      attrs[:kid_id] = create(:kid).id
      expect { post :create, attrs }.to raise_error(CanCan::AccessDenied)
    end

    it 'should not be able to taint kid_id via journal attributes' do
      attrs = valid_attributes
      attrs[:journal][:kid_id] = create(:kid).id
      post :create, attrs
      expect(assigns(:journal).kid).to eq(kid)
    end
  end # end of as a mentor

  # valid attributes to create a journal
  # this uses strings for time and date fields, since this is what we
  # want to submit via the jquery widgets
  def valid_attributes
    attrs = {}
    attrs[:journal] = attributes_for(:journal,
                                     mentor_id: mentor.id,
                                     held_at: '2011-05-30',
                                     start_at: '12:00',
                                     end_at: '12:30')
    attrs[:kid_id] = kid.id
    attrs
  end
end
