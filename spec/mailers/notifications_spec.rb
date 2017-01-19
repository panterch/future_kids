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

  describe 'journal' do
    before(:each) do
      @admin    = create(:admin, email: 'admin@example.com')
      @mentor   = create(:mentor)
      @kid1     = create(:kid, mentor: @mentor, admin: @admin)
      @kid2     = create(:kid, mentor: @mentor)
      @journal1 = create(:journal, kid: @kid1, mentor: @mentor, held_at: '2017-01-19',
                         important: true, start_at: '13:30', end_at: '14:00')
      @journal2 = create(:journal, kid: @kid2, mentor: @mentor, held_at: '2017-01-19',
                         important: true, start_at: '13:30', end_at: '14:00')
      @journal3 = create(:journal, kid: @kid1, mentor: @mentor, held_at: '2017-01-18',
                         important: false, start_at: '13:30', end_at: '14:00')
      @mail1    = Notifications.important_journal_created(@journal1)
      @mail2    = Notifications.important_journal_created(@journal2)
      @mail3    = Notifications.important_journal_created(@journal3)
    end

    it 'delivers the emails that should be sent at the start of the test' do
      expect(ActionMailer::Base.deliveries).not_to be_empty
      expect(ActionMailer::Base.deliveries.length).to eq(2)
    end

    it 'renders the headers' do
      expect(@mail1.subject).to eq(I18n.t('notifications.important_subject'))
      expect(@mail2.subject).to eq(I18n.t('notifications.important_subject'))
      expect(@mail1.to).to eq(['futurekids-tech@panter.ch', @admin.email])
      expect(@mail2.to).to eq(['futurekids-tech@panter.ch'])
      expect(@mail1.from).to eq(['futurekids-tech@panter.ch'])
      expect(@mail2.from).to eq(['futurekids-tech@panter.ch'])
    end

    it 'renders the body' do
      expect(@mail1.body.encoded).to match('Liebe Lehrperson')
      expect(@mail2.body.encoded).to match('Liebe Lehrperson')
      expect(@mail1.body.encoded).to match(@journal1.kid.name)
      expect(@mail2.body.encoded).to match(@journal2.kid.name)
    end
  end
end