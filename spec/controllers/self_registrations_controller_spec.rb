require 'spec_helper'

describe SelfRegistrationsController do

  context 'enabled' do 
    before do 
      Site.load.update(public_signups_active: true)
    end

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
        let(:params) { { teacher: attributes_for(:teacher).merge(type: 'Teacher'), terms_of_use: { accepted: "yes" } } }
  
        before do
          post :create, params: params
        end

        it 'creates teacher' do
          expect(Teacher.count).to eq 1
        end

        it 'redirect to success if created' do
          expect(response).to redirect_to action: :success
        end

        it 'created teacher has selfservice status' do
          expect(Teacher.first.state).to eq 'selfservice'
        end

        it "can't force state" do
          post :create, params: params.deep_merge({ teacher: { state: :accepted, email: attributes_for(:teacher)[:email] }})
          expect(response).to redirect_to action: :success
          expect(Teacher.last.state).to eq 'selfservice'
        end

        it "can't be created if not accepted terms of conditions" do
          post :create, params: params.deep_merge({ teacher: { email: attributes_for(:teacher)[:email] }}).except(:terms_of_use)
          expect(response).to have_http_status :success
        end
      end
      context 'mentor' do
        let(:params) {{ mentor: attributes_for(:mentor).merge(type: 'Mentor'), terms_of_use: { accepted: "yes" } }}
        before do
          post :create, params: params
        end

        it 'creates mentor' do
          expect(Mentor.count).to eq 1
        end

        it 'redirect to success if created' do
          expect(response).to redirect_to action: :success
        end

        it 'created teacher has selfservice status' do
          expect(Mentor.first.state).to eq 'selfservice'
        end

        it 'sends email to all admins' do
          last_email = ActionMailer::Base.deliveries.last
          expect(last_email.to).to eq [admin.email, admin2.email]
        end

        it "can't force state" do
          post :create, params: params.deep_merge({ mentor: { state: :accepted, email: attributes_for(:mentor)[:email] } })
          expect(response).to redirect_to action: :success
          expect(Mentor.last.state).to eq 'selfservice'
        end

        it "can't be created if not accepted terms of conditions" do
          post :create, params: params.deep_merge({ mentor: { email: attributes_for(:mentor)[:email] }}).except(:terms_of_use)
          expect(response).to have_http_status :success
        end
      end
    end

    context 'success' do
      it 'renders' do
        get :success
        expect(response).to be_successful
      end
    end

    context 'terms_of_use' do
      it 'renders' do
        get :terms_of_use
        expect(response).to be_successful
      end
    end
  end

  context 'disabled' do 
    context 'new' do
      it 'redirect to sign_in' do
        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'create' do
      let(:teacher_params) { attributes_for(:teacher).merge(type: 'Teacher') }
      it 'redirect to sign_in' do
        post :create, params: { teacher: teacher_params }
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'success' do 
      it 'redirect to sign_in' do
        get :success
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'terms_of_use' do 
      it 'redirect to sign_in' do
        get :terms_of_use
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end