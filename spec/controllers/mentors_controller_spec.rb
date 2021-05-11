require 'spec_helper'

describe MentorsController do
  context 'as a mentor' do
    before(:each) do
      @mentor = create(:mentor)
      sign_in @mentor
    end

    context 'show' do
      before(:each) do
        @journal = create(:journal, mentor: @mentor, held_at: '2011-01-01')
      end

      it 'assigns no journal entries when no available' do
        get :show, params: { id: @mentor }
        expect(assigns(:journals).size).to eq(1) # default entry
      end

      it 'assigns the pre-created journal entries when no available' do
        get :show, params: { id: @mentor, month: '1', year: '2011' }
        expect(assigns(:journals)).to include(@journal)
      end
    end

    context 'edit_schedules' do
      it 'updates the schedule seen timestamp' do
        get :edit_schedules, params: { id: @mentor.id }
        expect(@mentor.reload.schedules_seen_at).not_to be_nil
      end
    end

    context 'update_schedules' do
      it 'creates schedule entries' do
        put :update_schedules, params: { id: @mentor.id, mentor: {
          schedules_attributes: [
            { day: 1, hour: 15, minute: 0 },
            { day: 2, hour: 16, minute: 30 }
          ] } }
        expect(@mentor.reload.schedules.count).to eq(2)
      end
    end

    context 'update' do 
      it 'cannot update its state' do
        expect do
          put :update, params: { id: @mentor.id, mentor: { state: :cancelled } }
        end.to raise_error(SecurityError)

        expect(@mentor.reload.state).to eq 'confirmed'
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

      it 'excludes inactive mentors' do
        create(:mentor, inactive: true)
        get :index
        expect(assigns(:mentors).size).to eq(1)
      end

      it 'renders xlsx' do
        get :index, format: 'xlsx'
        expect(response).to be_successful
      end
    end

    context 'edit_schedules' do
      it 'does not update the schedule seen timestamp' do
        get :edit_schedules, params: { id: @mentor.id }
        expect(@mentor.reload.schedules_seen_at).to be_nil
      end
    end

    context 'update' do
      it 'can update state' do
        @teacher = create(:teacher)
        patch :update, params: { id: @mentor.id, mentor: {
            state: :cancelled} }
        expect(@mentor.reload.state).to eq 'cancelled'
      end
    end

  end
end
