require 'spec/spec_helper'

describe JournalsController do

  before(:each) do
    @mentor = Factory(:mentor)
    @kid = Factory(:kid, :mentor => @mentor)
  end

  let(:journal) { Factory(:journal, :kid => @kid, :mentor => @mentor) }
  let(:secondary_kid) { Factory(:kid, :secondary_mentor => @mentor,
                                      :secondary_active => true) }

  context 'as an admin' do
    before(:each) do
      @admin = Factory(:admin)
      sign_in @admin
    end

    it 'should render the new template' do
      get :new, :kid_id => @kid.id
      response.should be_successful
      response.should render_template(:new)
    end

    it 'should render assign only selectable mentors' do
      @foreign_mentor = Factory(:mentor)
      get :new, :kid_id => @kid.id
      assigns(:mentors).should eq([@mentor])
    end

    it 'should not access new when no mentors available' do
      Mentor.destroy_all
      get :new, :kid_id => @kid.id
      response.should be_redirect
    end

    it 'should create a new entry posting valid attributes' do
      post :create, valid_attributes
      assigns(:journal).should_not be_new_record
    end

    it 'should parse ch date formatted strings for held_at' do
      attrs = valid_attributes
      attrs[:journal][:held_at] = '31.12.2010'
      post :create, attrs
      assigns(:journal).held_at.should eq(Date.parse('2010-12-31'))
    end

    context 'with render views' do
      render_views
      it('news') { get :new, :kid_id => @kid.id }
      it('edits') { get :edit, :kid_id => @kid.id, :id => journal.id }
    end
  end # end of 'as an admin'

  context 'as a mentor' do
    before(:each) do
      sign_in @mentor
    end
  
    it 'should render the new template' do
      get :new, :kid_id => @kid.id
      response.should be_successful
    end

    it 'should render the new template for secondary kids' do
      get :new, :kid_id => secondary_kid.id
      response.should be_successful
    end

    it 'should not render the new template for inactive secondary kids' do
      inactive_kid = Factory(:kid, :secondary_mentor => @mentor,
                                   :secondary_active => false)
      expect { get :new, :kid_id => inactive_kid.id }.to
        raise_error(CanCan::AccessDenied)
    end

    it 'should not assign mentors for selectbox' do
      get :new, :kid_id => @kid.id
      assigns(:mentors).should be_nil
    end

    it 'should deny access for foreign kids' do
      expect { get :new, :kid_id => Factory(:kid).id }.to
        raise_error(CanCan::AccessDenied)
    end

    it 'should create a new entry' do
      post :create, valid_attributes
      assigns(:journal).should_not be_new_record
    end

    it 'should not be able to create entries for other mentors' do
      attrs = valid_attributes
      attrs[:journal][:mentor_id] = Factory(:mentor).id
      post :create, attrs
      assigns(:journal).mentor.should eq(@mentor)
    end

    it 'should not be able to create entries for other kids' do
      attrs = valid_attributes
      attrs[:kid_id] = Factory(:kid).id
      expect { post :create, attrs }.to
        raise_error(CanCan::AccessDenied)
    end

    it 'should not be able to taint kid_id via journal attributes' do
      attrs = valid_attributes
      attrs[:journal][:kid_id] = Factory(:kid).id
      expect { post :create, attrs }.to
        raise_error(CanCan::AccessDenied)
    end
  end # end of as a mentor

  # valid attributes to create a journal
  # this uses strings for time and date fields, since this is what we
  # want to submit via the jquery widgets
  def valid_attributes
    attrs = {}
    attrs[:journal] =  Factory.attributes_for(:journal,
      :mentor_id => @mentor.id,
      :held_at   => '2011-05-30',
      :start_at  => '12:00',
      :end_at    => '12:30')
    attrs[:kid_id] = @kid.id
    attrs
  end

end
