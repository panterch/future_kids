require 'spec_helper'

describe MentorsController do
  context 'as a mentor' do

    before(:each) do
      @mentor = create(:mentor)
      sign_in @mentor
    end

    context 'show' do
      before(:each) do
        @journal = create(:journal, :mentor => @mentor, :held_at => '2011-01-01')
      end

      it 'assigns no journal entries when no available' do
        get :show, :id => @mentor
        expect(assigns(:journals).size).to eq(1) # default entry
      end

      it 'assigns the precreated journal entries when no available' do
        get :show, :id => @mentor, :month => '1', :year => '2011'
        expect(assigns(:journals)).to include(@journal)
      end
    end

    context 'update_schedules' do
      it 'creates schedule entries' do
        put :update_schedules, :id => @mentor.id, :mentor => {
                :schedules_attributes => [
                    {:day => 1, :hour => 15, :minute => 0},
                    {:day => 2, :hour => 16, :minute => 30}
                ]}
        expect(@mentor.reload.schedules.count).to eq(2)
      end
    end
  end

  context 'as an admin' do
    before(:each) do
      @admin = create(:admin)
      sign_in @admin
      @mentor = create(:mentor)
    end

    context 'index' do
      it 'assigns two mentors in the index' do
        create(:mentor)
        get :index
        expect(assigns(:mentors).size).to eq(2)
      end

      it 'renders xlsx' do
        get :index, format: 'xlsx'
        expect(response).to be_successful
      end

    end
  end
end
