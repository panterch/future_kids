# frozen_string_literal: true

class NotificationsMailerPreview < ActionMailer::Preview
  def test
    NotificationsMailer.test('test@example.com')
  end

  def journals_created
    # fall back gracefully when the development database holds no seed data
    teacher = Teacher.last || Teacher.new(email: 'preview@example.com')
    journals = [Journal.first, Journal.last].compact.uniq
    NotificationsMailer.journals_created(teacher, journals)
  end
end
