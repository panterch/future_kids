require 'spec_helper'

describe Notifications do
  describe 'remind' do
    before(:each) do
      @reminder = create(:reminder)
      @mail = Notifications.remind(@reminder)
    end

    it 'no deliveries at the start of the test' do
      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'renders the headers' do
      expect(@mail.subject).to match('Erinnerung')
      expect(@mail.to).to eq([@reminder.mentor.email])
      expect(@mail.from).to eq(['futurekids-tech@panter.ch'])
    end

    it 'renders the body' do
      expect(@mail.body.encoded).to match('Lieber')
      expect(@mail.body.encoded).to match(@reminder.kid.name)
    end

    it 'delivers the email' do
      @mail.deliver_now
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end
  end

  describe 'reminders created' do
    before(:each) do
      @mail = Notifications.reminders_created(10)
    end

    it 'renders the body' do
      expect(@mail.body.encoded).to match('Liebe')
    end
  end

  describe 'comment created' do
    before(:each) do
      @comment = create(:comment)
      @mail = Notifications.comment_created(@comment)
    end

    it 'renders the body' do
      expect(@mail.body.encoded).to match('Liebe')
    end
  end
end
