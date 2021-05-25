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
          put :update, params: { id: @mentor.id, mentor: { state: :declined } }
        end.to raise_error(SecurityError)

        expect(@mentor.reload.state).to eq 'accepted'
      end
    end

    context 'disable_no_kids_reminder' do
      let!(:other_mentor) { create(:mentor) }
      it 'disables no_kids_reminder' do
        get :disable_no_kids_reminder, params: { id: @mentor.id }
        expect(@mentor.reload.no_kids_reminder).to eq false
      end

      it 'is not allowed disable reminder for other mentor' do
        expect {
          get :disable_no_kids_reminder, params: { id: other_mentor.id }
        }.to raise_error CanCan::AccessDenied
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
        patch :update, params: { id: @mentor.id, mentor: { state: :declined } }
        expect(@mentor.reload.state).to eq 'declined'
      end

      it 'sends email if state updated to accepted' do
        @mentor.update(state: :selfservice)
        patch :update, params: { id: @mentor.id, mentor: { state: :accepted } }
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq I18n.translate('self_registrations_mailer.reset_and_send_password.subject')
      end

      it "doesn't send an email if update other fields than state" do
        patch :update, params: { id: @mentor.id, mentor: { first_name: 'Karl' } }
        expect(ActionMailer::Base.deliveries.count).to eq 0
      end

      it 'resends email with password with resend password button if user is accepted' do
        patch :update, params: { id: @mentor.id, commit: I18n.translate('teachers.form.resend_password.btn_text') }
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.subject).to eq I18n.translate('self_registrations_mailer.reset_and_send_password.subject')
      end
    end
  end
end
