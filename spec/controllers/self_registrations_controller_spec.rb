require 'spec_helper'

describe SelfRegistrationsController do
  context 'new' do
    it 'renders' do
      get :new
      expect(response).to be_successful
    end
  end

  context 'create' do
    let!(:admin) { create(:admin) }
    let!(:admin2) { create(:admin) }
    context 'teacher' do
      let(:teacher_params) { attributes_for(:teacher).merge(type: 'Teacher') }
      before do
        post :create, params: { teacher: teacher_params }
      end

      it 'creates teacher' do
        expect(Teacher.count).to eq 1
      end

      it 'redirect to success if created' do
        expect(response).to redirect_to action: :success
      end

      it 'created teacher has unproven status' do
        expect(Teacher.first.state).to eq 'unproven'
      end

      it 'sends email to all admins' do
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [admin.email, admin2.email]
      end

      it "can't force state" do
        post :create, params: { teacher: attributes_for(:teacher).merge(type: 'Teacher', state: :confirmed) }
        expect(response).to redirect_to action: :success
        expect(Teacher.last.state).to eq 'unproven'
      end
    end

    context 'mentor' do
      let(:mentor_params) { attributes_for(:mentor).merge(type: 'Mentor') }
      before do
        post :create, params: { mentor: mentor_params }
      end

      it 'creates mentor' do
        expect(Mentor.count).to eq 1
      end

      it 'redirect to success if created' do
        expect(response).to redirect_to action: :success
      end

      it 'created teacher has unproven status' do
        expect(Mentor.first.state).to eq 'unproven'
      end

      it 'sends email to all admins' do
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to eq [admin.email, admin2.email]
      end

      it "can't force state" do
        post :create, params: { mentor: attributes_for(:mentor).merge(type: 'Mentor', state: :confirmed) }
        expect(response).to redirect_to action: :success
        expect(Mentor.last.state).to eq 'unproven'
      end
    end
  end

  context 'success' do
    it 'renders' do
      get :new
      expect(response).to be_successful
    end
  end
end