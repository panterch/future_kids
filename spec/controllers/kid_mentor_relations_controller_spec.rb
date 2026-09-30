# frozen_string_literal: true

require 'spec_helper'

describe KidMentorRelationsController do
  context 'as a admin' do
    before do
      @admin = create(:admin)
      @mentor = create(:mentor)
      create(:kid, mentor: @mentor)
      sign_in @admin
    end

    context 'index' do
      it 'displays index' do
        create(:kid)
        get :index
        expect(assigns(:kid_mentor_relations).length).to eq(2)
      end

      it 'filters kids when criteria given' do
        create(:kid, exit_kind: 'exit', mentor: @mentor)
        get :index, params: { kid_mentor_relation: { kid_exit_kind: 'exit' } }
        expect(assigns(:kid_mentor_relations).length).to eq(1)
      end

      it 'renders xlsx' do
        create(:kid)
        create(:kid, exit_kind: 'exit', mentor: @mentor)
        get :index, format: 'xlsx'
        expect(response).to be_successful
        expect(response.headers['Content-Disposition'])
          .to match(/filename="kid-mentor-relations-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}\.xlsx"/)
      end
    end
  end

  context 'as an admin updating the exit kind' do
    let(:mentor) { create(:mentor) }
    let(:kid) { create(:kid, mentor: mentor) }

    before { sign_in create(:admin) }

    it 'sets the exit kind of the kid' do
      patch :update_kid, params: { kid_id: kid.id, kid: { exit_kind: 'continue' } }
      expect(response).to have_http_status(:no_content)
      expect(kid.reload.exit_kind).to eq('continue')
    end

    it 'sets the exit kind of the mentor and tracks the update time' do
      patch :update_mentor, params: { mentor_id: mentor.id, mentor: { exit_kind: 'exit' } }
      expect(response).to have_http_status(:no_content)
      expect(mentor.reload.exit_kind).to eq('exit')
      expect(mentor.exit_kind_updated_at).to be_present
    end

    it 'clears the exit kind when blank' do
      kid.update!(exit_kind: 'exit')
      patch :update_kid, params: { kid_id: kid.id, kid: { exit_kind: '' } }
      expect(kid.reload.exit_kind).to be_nil
    end

    it 'accepts later' do
      patch :update_kid, params: { kid_id: kid.id, kid: { exit_kind: 'later' } }
      expect(response).to have_http_status(:no_content)
      expect(kid.reload.exit_kind).to eq('later')
    end

    it 'sets the exit date of the kid' do
      patch :update_kid, params: { kid_id: kid.id, kid: { exit_at: '2026-12-24' } }
      expect(response).to have_http_status(:no_content)
      expect(kid.reload.exit_at).to eq(Date.new(2026, 12, 24))
    end

    it 'sets and clears the exit date of the mentor' do
      patch :update_mentor, params: { mentor_id: mentor.id, mentor: { exit_at: '2026-12-24' } }
      expect(mentor.reload.exit_at).to eq(Date.new(2026, 12, 24))
      patch :update_mentor, params: { mentor_id: mentor.id, mentor: { exit_at: '' } }
      expect(mentor.reload.exit_at).to be_nil
    end

    it 'does not accept too old dates' do
      expect { patch :update_kid, params: { kid_id: kid.id, kid: { exit_at: '1999-01-01' } } }
        .to raise_error(ActiveRecord::RecordInvalid)
      expect(kid.reload.exit_at).to be_nil
    end

    it 'accepts the earliest allowed date' do
      patch :update_kid, params: { kid_id: kid.id, kid: { exit_at: ApplicationRecord::MIN_DATE.iso8601 } }
      expect(kid.reload.exit_at).to eq(ApplicationRecord::MIN_DATE)
    end

    it 'does not accept unknown values' do
      expect { patch :update_kid, params: { kid_id: kid.id, kid: { exit_kind: 'other' } } }
        .to raise_error(ActiveRecord::RecordInvalid)
      expect { patch :update_mentor, params: { mentor_id: mentor.id, mentor: { exit_kind: 'other' } } }
        .to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'does not find an unknown mentor' do
      expect { patch :update_mentor, params: { mentor_id: 0, mentor: { exit_kind: 'exit' } } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'requires the params of the person' do
      expect { patch :update_kid, params: { kid_id: kid.id, mentor: { exit_kind: 'exit' } } }
        .to raise_error(ActionController::ParameterMissing)
    end

    it 'sets exit kind and date together' do
      patch :update_kid, params: { kid_id: kid.id, kid: { exit_kind: 'later', exit_at: '2026-12-24' } }
      expect(response).to have_http_status(:no_content)
      expect(kid.reload).to have_attributes(exit_kind: 'later', exit_at: Date.new(2026, 12, 24))
    end
  end

  context 'as a mentor' do
    before do
      @mentor = create(:mentor)
      sign_in @mentor
    end

    context 'update' do
      it 'denies access' do
        kid = create(:kid, mentor: @mentor)
        expect do
          patch :update_kid, params: { kid_id: kid.id, kid: { exit_kind: 'exit' } }
        end.to raise_error(SecurityError)
        expect(kid.reload.exit_kind).to be_nil
      end
    end

    context 'index' do
      it 'denies access' do
        expect { get :index }.to raise_error(SecurityError)
      end
    end
  end
end
