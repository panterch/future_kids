require 'spec_helper'

describe RemindersController do

  before(:each) do
    @admin = create(:admin)
    @reminder = create(:reminder)
    sign_in @admin
  end

  context 'index' do

    it 'should index' do
      get :index
      expect(response).to be_successful
    end

    it 'should not display acknowledged reminders' do
      create(:reminder, :acknowledged_at => Time.now)
      get :index
      expect(assigns(:reminders)).to eq([@reminder])
    end

  end

  context 'update' do
    it 'delivers the reminder' do
      put :update, id: @reminder.id
      expect(response).to redirect_to(action: 'index')
      expect(@reminder.reload.sent_at).to_not be_nil
    end
  end

  context 'destroy' do
    it 'delivers the reminder' do
      put :destroy, id: @reminder.id
      expect(response).to redirect_to(action: 'index')
      expect(Reminder.active.count).to eq(0)
      expect(Reminder.count).to eq(1) # soft delete
    end
  end

end
