# frozen_string_literal: true

require 'spec_helper'

describe MentorsController do
  context 'as a mentor' do
    before do
      @mentor = create(:mentor)
      sign_in @mentor
    end

    context 'show' do
      before do
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

    context 'update_schedules' do
      it 'creates schedule entries' do
        put :update_schedules, params: { id: @mentor.id, mentor: {
          schedules_attributes: [
            { day: 1, hour: 15, minute: 0 },
            { day: 2, hour: 16, minute: 30 }
          ]
        } }
        expect(@mentor.reload.schedules.count).to eq(2)
      end

      it 'keeps the existing schedule and alerts when the mentor does not validate' do
        create(:schedule, person: @mentor, day: 1, hour: 14, minute: 0)
        @mentor.update_columns(dob: Date.new(1800, 1, 1)) # rubocop:disable Rails/SkipsModelValidations
        expect(@mentor.reload).not_to be_valid

        put :update_schedules, params: { id: @mentor.id, mentor: {
          schedules_attributes: [{ day: 2, hour: 15, minute: 30 }]
        } }

        expect(@mentor.schedules.pluck(:day, :hour, :minute)).to eq([[1, 14, 0]])
        expect(flash[:alert]).to eq(I18n.t('flash.schedules_not_saved'))
      end
    end

    context 'update' do
      it 'can update its own record' do
        put :update, params: { id: @mentor.id, mentor: { name: 'changed' } }
        expect(@mentor.reload.name).to eq('changed')
      end

      it 'does not allow setting ects' do
        expect do
          put :update, params: { id: @mentor.id, mentor: { ects: 30 } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow setting the personnel number' do
        expect do
          put :update, params: { id: @mentor.id, mentor: { personnel_number: '1337' } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow setting the exit status' do
        expect do
          put :update, params: { id: @mentor.id, mentor: { exit_kind: 'other' } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow setting the inactive flag' do
        expect do
          put :update, params: { id: @mentor.id, mentor: { inactive: true } }
        end.to raise_error(SecurityError)
      end
    end
  end

  # the kids and schools listed on the mentor page: only those of kids the
  # viewer may read, as can_link_to prints the name of a kid it doesn't link
  context 'show page lists' do
    render_views

    let(:mentor) { create(:mentor) }
    let(:shared_school) { create(:school, name: 'Schule des gemeinsamen Kindes') }
    let(:other_school) { create(:school, name: 'Schule des anderen Kindes') }
    let(:teacher) { create(:teacher) }
    let(:partner) { create(:mentor) }

    before do
      create(:kid, name: 'Gemeinsames', prename: 'Kind', mentor: mentor, secondary_mentor: partner,
                   secondary_active: true, teacher: teacher, school: shared_school,
                   city: '8001 Zürich', meeting_day: 1)
      create(:kid, name: 'Anderes', prename: 'Kind', mentor: mentor, school: other_school,
                   city: '3000 Bern', meeting_day: 3)
      create(:kid, name: 'Zweitkind', prename: 'Kind', secondary_mentor: mentor, secondary_active: true,
                   city: '4000 Basel', school: other_school)
    end

    def expect_only_the_shared_kid
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Gemeinsames, Kind', '8001 Zürich', 'Schule des gemeinsamen Kindes')
      expect(response.body).not_to include('Anderes', '3000 Bern', 'Zweitkind', 'Schule des anderen Kindes')
    end

    it 'shows a teacher only the kids of the mentor the teacher may read' do
      sign_in teacher
      get :show, params: { id: mentor.id }
      expect_only_the_shared_kid
    end

    it 'shows a partner mentor only the kids of the mentor the partner may read' do
      sign_in partner
      get :show, params: { id: mentor.id }
      expect_only_the_shared_kid
    end

    it 'shows an admin all kids and schools of the mentor' do
      sign_in create(:admin)
      get :show, params: { id: mentor.id }
      expect(response.body).to include('Gemeinsames', 'Anderes', 'Zweitkind',
                                       'Schule des gemeinsamen Kindes', 'Schule des anderen Kindes')
    end

    it 'shows the mentor all own kids, as first and as second mentor' do
      sign_in mentor
      get :show, params: { id: mentor.id }
      expect(response.body).to include('Gemeinsames', 'Anderes', 'Zweitkind', '3000 Bern', '4000 Basel',
                                       'Schule des anderen Kindes')
    end
  end

  context 'as an admin' do
    before do
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
        expect(response.headers['Content-Disposition'])
          .to match(/filename="mentors-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}\.xlsx"/)
      end

      # the filters find mentors by one of their kids; the export still
      # lists all kids of the mentors found
      it 'exports all kids of a mentor found by the meeting day of one of them' do
        monday_kid = create(:kid, mentor: @mentor, meeting_day: 1)
        tuesday_kid = create(:kid, mentor: @mentor, meeting_day: 2)
        get :index, format: 'xlsx', params: { mentor: { filter_by_meeting_day: 1 } }
        exported = assigns(:mentors).to_a
        expect(exported).to eq([@mentor])
        expect(exported.first.kids).to contain_exactly(monday_kid, tuesday_kid)
      end
    end
  end
end
