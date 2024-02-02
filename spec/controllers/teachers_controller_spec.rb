require 'spec_helper'

describe TeachersController do
  context 'as an admin' do
    before(:each) do
      @admin = create(:admin)
      sign_in @admin
    end

    context 'index' do
      it 'assigns two teachers in the index' do
        2.times { create(:teacher) }
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
        expect(Teacher.exists?(@teacher.id)).to be_falsey
      end

      it 'cannot destroy active' do
        @teacher = create(:teacher)
        expect do
          delete :destroy, params: { id: @teacher.id }
        end.to raise_error(CanCan::AccessDenied)
        expect(Teacher.exists?(@teacher.id)).to be_truthy
      end
    end

  end



  context 'as a principal' do
    before(:each) do
      @school = create(:school)
      @principal = create(:principal, schools: [ @school])
      sign_in @principal
    end

    context 'index' do
      before(:each) do
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
      before(:each) do
        @school = create(:school)
        @teacher = create(:teacher, school: @school)
        sign_in @teacher
      end

      it 'can update its own record' do
        put :update, params: { id: @teacher.id, teacher: {
          name: 'changed' } }
        expect(response).to be_redirect
        expect(@teacher.reload.name).to eq('changed')
      end

      it 'cannot update its own school or inactivity' do
        @original_school = @teacher.school
        @school = create(:school)
        expect do
          put :update, params: { id: @teacher.id, teacher: {
            school_id: @school.id  } }
        end.to raise_error(SecurityError)
        expect(@teacher.reload.school).to_not eq(@school)
      end
      
    end
  end
end

