# frozen_string_literal: true

require 'spec_helper'

describe KidsController do
  context 'as a mentor' do
    before do
      @mentor = create(:mentor)
      @kid = create(:kid, mentor: @mentor)
      sign_in @mentor
    end

    context 'index' do
      it 'renders' do
        get :index
        expect(response).to be_successful
        expect(assigns(:kids).length).to eq(1)
      end
    end

    context 'schedules' do
      it 'does not allow displaying the kids schedule' do
        expect_access_denied { get :edit_schedules, params: { id: @kid } }
      end

      it 'does not allow updating the kids schedule' do
        expect_access_denied { post :update_schedules, params: { id: @kid } }
      end
    end
  end

  context 'as a admin' do
    before do
      @admin = create(:admin)
      @kid = create(:kid)
      sign_in @admin
    end

    context 'index' do
      it 'filters kids when criteria given' do
        create(:kid, translator: true)
        create(:kid, translator: true)
        get :index, params: { kid: { translator: '1' } }
        expect(assigns(:kids).length).to eq(2)
      end

      it 'orders kids by criticality' do
        @low  = create(:kid, abnormality_criticality: 3)
        @high = create(:kid, abnormality_criticality: 1)
        get :index, params: { order_by: 'abnormality_criticality' }
        expect(assigns(:kids).first).to eq(@high)
        expect(assigns(:kids).second).to eq(@low)
        expect(assigns(:kids).last).to eq(@kid)
      end

      it 'creates a criteria instance for search' do
        get :index, params: { kid: { translator: '1' } }
        expect(assigns(:kid).translator).to be(true)
      end

      it 'excludes inactive kids' do
        create(:kid, inactive: true)
        get :index
        expect(response).to be_successful
        expect(assigns(:kids).length).to eq(1)
      end

      it 'renders xlsx' do
        get :index, format: 'xlsx'
        expect(response).to be_successful
        expect(response.headers['Content-Disposition']).to match(/filename="kids-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}\.xlsx"/)
      end
    end

    context 'edit_schedules' do
      it 'displays the kids schedule' do
        get :edit_schedules, params: { id: @kid }
        expect(response).to be_successful
      end
    end

    context 'update_schedules' do
      it 'creates a new schedule' do
        post :update_schedules, params: { id: @kid, kid: { schedules_attributes: [attributes_for(:schedule)] } }
        expect(response).to be_redirect
        expect(@kid.schedules.count).to eq(1)
      end
    end

    context 'destroy' do
      it 'can destroy inactive' do
        @kid.update(inactive: true)
        delete :destroy, params: { id: @kid.id }
        expect(Kid).not_to exist(@kid.id)
      end

      it 'cannot destroy active' do
        expect_access_denied do
          delete :destroy, params: { id: @kid.id }
        end
        expect(Kid).to exist(@kid.id)
      end
    end
  end

  context 'as a teacher' do
    before do
      @school = create(:school)
      @teacher = create(:teacher, school: @school)
      sign_in @teacher
    end

    context 'update' do
      it 'does not allow moving an assigned kid to a foreign school' do
        kid = create(:kid, teacher: @teacher, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { school_id: create(:school).id } }
        end.to raise_error(SecurityError)
      end
    end

    context 'create' do
      it 'assigns itself as teacher' do
        post :create, params: { kid: attributes_for(:kid, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.teacher).to eq(@teacher)
        expect(kid.school).not_to be_nil
        expect(kid.school).to eq(@school)
        expect(response).to be_redirect
      end

      it 'assigns itself as teacher even when secondary teacher set' do
        @secondary = create(:teacher)
        post :create, params: { kid: attributes_for(:kid, secondary_teacher_id: @secondary.id, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.teacher).to eq(@teacher)
        expect(kid.secondary_teacher).to eq(@secondary)
        expect(kid.school).not_to be_nil
        expect(response).to be_redirect
      end

      it 'can assign itself as secondary teacher' do
        post :create, params: { kid: attributes_for(:kid, secondary_teacher_id: @teacher.id, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.teacher).to be_nil
        expect(kid.secondary_teacher).to eq(@teacher)
        expect(kid.school).to eq(@school)
        expect(response).to be_redirect
      end

      it 'cannot assign a foreign school' do
        expect do
          post :create, params: { kid: attributes_for(:kid, school_id: 'non-existant') }
        end.to raise_error SecurityError
      end

      it 'tracks creation as relationlog' do
        post :create, params: { kid: attributes_for(:kid) }
        expect(RelationLog.where(role: 'creator').count).to eq(1)
        rl = RelationLog.where(role: 'creator').first
        expect(rl.user).to eq(@teacher)
        expect(rl.role).to eq('creator')
        expect(rl.kid).to eq(assigns(:kid))
      end

      it 'does not track creation on form error' do
        post :create, params: { kid: {} }
        expect(RelationLog.where(role: 'creator').count).to eq(0)
      end
    end
  end

  context 'as a principal' do
    before do
      @school = create(:school)
      @principal = create(:principal, schools: [@school])
      sign_in @principal
    end

    context 'create' do
      it 'is able to create' do
        post :create, params: { kid: attributes_for(:kid, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.school).to eq(@school)
        expect(response).to be_redirect
      end
    end

    it 'cannot assign a foreign school' do
      expect do
        post :create, params: { kid: attributes_for(:kid, school_id: 'non-existant') }
      end.to raise_error SecurityError
    end

    context 'index' do
      it 'lists only kids of own schools' do
        own_kid = create(:kid, school: @school)
        create(:kid, school: create(:school))
        get :index
        expect(assigns(:kids)).to eq([own_kid])
      end
    end

    context 'update' do
      it 'updates kids of own schools' do
        kid = create(:kid, school: @school)
        put :update, params: { id: kid.id, kid: { name: 'Changed' } }
        expect(kid.reload.name).to eq('Changed')
      end

      it 'denies updating kids of foreign schools' do
        kid = create(:kid, school: create(:school))
        expect_access_denied do
          put :update, params: { id: kid.id, kid: { name: 'Changed' } }
        end
      end

      it 'does not allow moving a kid to a foreign school' do
        kid = create(:kid, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { school_id: create(:school).id } }
        end.to raise_error(SecurityError)
      end
    end
  end
end
