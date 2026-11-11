# frozen_string_literal: true

require 'spec_helper'

describe TeachersController do
  context 'as an admin' do
    before do
      @admin = create(:admin)
      sign_in @admin
    end

    context 'index' do
      it 'assigns two teachers in the index' do
        create_list(:teacher, 2)
        get :index
        expect(assigns(:teachers).size).to eq(2)
      end

      it 'excludes inactive teachers by default' do
        create(:teacher, inactive: true)
        get :index
        expect(assigns(:teachers).size).to eq(0)
      end

      it 'filters for inactive teacher' do
        create(:teacher, inactive: true)
        get :index, params: { inactive: '1' }
        expect(assigns(:teachers).size).to eq(0)
      end
    end

    context 'show' do
      it 'renders' do
        @teacher = create(:teacher)
        get :show, params: { id: @teacher.id }
        expect(response).to be_successful
      end
    end

    context 'edit' do
      it 'renders' do
        @teacher = create(:teacher)
        get :edit, params: { id: @teacher.id }
        expect(response).to be_successful
      end
    end

    context 'destroy' do
      it 'can destroy inactive' do
        @teacher = create(:teacher, inactive: true)
        delete :destroy, params: { id: @teacher.id }
        expect(Teacher).not_to exist(@teacher.id)
      end

      it 'cannot destroy active' do
        @teacher = create(:teacher)
        expect_access_denied do
          delete :destroy, params: { id: @teacher.id }
        end
        expect(Teacher).to exist(@teacher.id)
      end
    end
  end

  context 'as a principal' do
    before do
      @school = create(:school)
      @principal = create(:principal, schools: [@school])
      sign_in @principal
    end

    context 'index' do
      before do
        @teacher = create(:teacher, school: @school)
      end

      it 'renders' do
        get :index
        expect(response).to be_successful
        expect(assigns(:teachers)).to eq([@teacher])
      end

      it 'shows only teachers of own school' do
        create(:teacher)
        get :index
        expect(response).to be_successful
        expect(assigns(:teachers)).to eq([@teacher])
      end
    end

    context 'create' do
      let(:teacher_params) { attributes_for(:teacher) }

      it 'can create teacher in own school' do
        teacher_params[:school_id] = @school.id
        put :create, params: { teacher: teacher_params }
        expect(response).to be_redirect
        expect(Teacher.count).to eq(1)
      end

      it 'fails when creating teacher for foreign schools' do
        teacher_params[:school_id] = create(:school).id
        expect { put :create, params: { teacher: teacher_params } }.to raise_error SecurityError
        expect(Teacher.count).to eq(0)
      end
    end

    context 'as a teacher' do
      before do
        @school = create(:school)
        @teacher = create(:teacher, school: @school)
        sign_in @teacher
      end

      it 'can update its own record' do
        put :update, params: { id: @teacher.id, teacher: {
          name: 'changed'
        } }
        expect(response).to be_redirect
        expect(@teacher.reload.name).to eq('changed')
      end

      it 'cannot update its own school' do
        @original_school = @teacher.school
        @school = create(:school)
        expect do
          put :update, params: { id: @teacher.id, teacher: {
            school_id: @school.id
          } }
        end.to raise_error(SecurityError)
        expect(@teacher.reload.school).not_to eq(@school)
      end

      it 'cannot update its own inactivity' do
        expect do
          put :update, params: { id: @teacher.id, teacher: { inactive: true } }
        end.to raise_error(SecurityError)
        expect(@teacher.reload.inactive).to be(false)
      end
    end
  end

  context 'as a mentor' do
    before do
      @mentor = create(:mentor)
      @teacher = create(:teacher)
      create(:kid, name: 'Eigenes', prename: 'Kind', mentor: @mentor, teacher: @teacher)
      sign_in @mentor
    end

    # the three lists of the teacher page are handled alike: whether the
    # teacher is first, second or third teacher of a kid makes no difference
    %i[teacher secondary_teacher third_teacher].each do |position|
      it "does not show a kid the mentor may not read (#{position})" do
        create(:kid, name: 'Fremdes', prename: 'Kind', position => @teacher)
        get :show, params: { id: @teacher.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Eigenes, Kind')
        expect(response.body).not_to include('Fremdes')
      end

      it "shows the own kid and may open the page (#{position})" do
        teacher = create(:teacher)
        create(:kid, name: 'Zweites', prename: 'Kind', mentor: @mentor, position => teacher)
        get :show, params: { id: teacher.id }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Zweites, Kind')
      end
    end
  end

  context 'as a teacher' do
    it 'sees the kids of all three lists on the own page' do
      teacher = create(:teacher)
      create(:kid, name: 'Erstes', teacher: teacher)
      create(:kid, name: 'Zweites', secondary_teacher: teacher)
      create(:kid, name: 'Drittes', third_teacher: teacher)
      sign_in teacher
      get :show, params: { id: teacher.id }
      expect(response.body).to include('Erstes').and include('Zweites').and include('Drittes')
    end
  end
end
