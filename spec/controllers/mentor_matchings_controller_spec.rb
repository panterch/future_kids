require 'spec_helper'

describe MentorMatchingsController do
  before do
    Site.load.update!(kids_schedule_hourly: false, public_signups_active: true)
  end

  context 'as a mentor' do
    let(:mentor) { create(:mentor) }
    let(:other_mentor) { create(:mentor) }
    let(:kid) { create(:kid, sex: 'm') }
    let(:kid_with_mentor) { create(:kid, mentor: other_mentor, sex: 'm') }
    let(:pending_mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'pending') }
    let(:other_pending_mentor_matching) do
      create(:mentor_matching, mentor: other_mentor, kid: kid_with_mentor, state: 'pending')
    end
    let(:reserved_mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'reserved') }

    before do
      sign_in mentor
    end

    context 'new' do
      it 'is not allowed to access other mentors new' do
        expect do
          get :new, params: { kid_id: kid_with_mentor.id }
        end.to raise_error CanCan::AccessDenied
      end

      it 'is allowed to access kid without mentor' do
        get :new, params: { kid_id: kid.id }
        expect(response).to be_successful
      end
    end

    context 'create' do
      it 'is not allowed to create matching for other mentors kid' do
        expect do
          post :create, params: { kid_id: kid_with_mentor.id, mentor_matching: { message: '' } }
        end.to raise_error CanCan::AccessDenied
      end

      it 'is allowed to create matching for kid without mentoer' do
        post :create, params: { kid_id: kid.id, mentor_matching: { message: '' } }
        expect(response).to redirect_to(available_kids_path)
      end
    end

    context 'accept' do
      it 'is not allowed to accept pending mentor matchings' do
        expect do
          put :accept, params: { id: pending_mentor_matching.id }
        end.to raise_error CanCan::AccessDenied
      end

      it 'is not allowed to accept reserved mentor matching' do
        expect do
          put :accept, params: { id: reserved_mentor_matching }
        end.to raise_error CanCan::AccessDenied
      end
    end

    context 'decline' do
      it 'is not allowed to decline pending mentor matchings' do
        expect do
          put :decline, params: { id: pending_mentor_matching.id }
        end.to raise_error CanCan::AccessDenied
      end

      it 'declines reserved mentor matching' do
        expect do
          put :decline, params: { id: reserved_mentor_matching }
        end.to change { reserved_mentor_matching.reload.state }.from('reserved').to('declined')
      end
    end

    context 'confirm' do
      it 'is not allowed to confirm pending mentor matchings' do
        expect do
          put :confirm, params: { id: pending_mentor_matching.id }
        end.to raise_error CanCan::AccessDenied
      end

      it 'confirms reserved mentor matching' do
        expect do
          put :confirm, params: { id: reserved_mentor_matching }
        end.to change { reserved_mentor_matching.reload.state }.from('reserved').to('confirmed')
      end

      it 'is not allowed to confirm reserved mentor matching of other mentor' do
        expect do
          put :confirm, params: { id: other_pending_mentor_matching }
        end.to raise_error CanCan::AccessDenied
      end
    end
  end
end
