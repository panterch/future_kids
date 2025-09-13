require 'spec_helper'

describe RemindersController do
  context 'as admin' do
    before do
      @admin = create(:admin)
      @reminder = create(:reminder)
      sign_in @admin
    end

    context 'index' do
      it 'indexes' do
        get :index
        expect(response).to be_successful
      end

      it 'does not display acknowledged reminders' do
        create(:reminder, acknowledged_at: Time.now)
        get :index
        expect(assigns(:reminders)).to eq([@reminder])
      end
    end

    context 'update' do
      it 'delivers the reminder' do
        put :update, params: { id: @reminder.id }
        expect(response).to redirect_to(action: 'index')
        expect(@reminder.reload.sent_at).not_to be_nil
      end
    end

    context 'destroy' do
      it 'delivers the reminder' do
        delete :destroy, params: { id: @reminder.id }
        expect(response).to redirect_to(action: 'index')
        expect(Reminder.active.count).to eq(0)
        expect(Reminder.count).to eq(1) # soft delete
      end
    end
  end

  it 'does not allow access to mentors' do
    sign_in create(:mentor)
    expect { get :index }.to raise_error(CanCan::AccessDenied)
  end

  it 'does not allow access to teachers' do
    sign_in create(:teacher)
    expect { get :index }.to raise_error(CanCan::AccessDenied)
  end
end
