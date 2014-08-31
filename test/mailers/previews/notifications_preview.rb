class NotificationsPreview < ActionMailer::Preview

  def test
    Notifications.test('test@example.com')
  end

  def journals_created
    Notifications.journals_created(Teacher.last, [ Journal.first, Journal.last])
  end

end
