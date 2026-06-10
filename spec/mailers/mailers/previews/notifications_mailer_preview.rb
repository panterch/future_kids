# frozen_string_literal: true

class NotificationsMailerPreview < ActionMailer::Preview
  def test
    NotificationsMailer.test('test@example.com')
  end

  def journals_created
    NotificationsMailer.journals_created(Teacher.last, [Journal.first, Journal.last])
  end
end
