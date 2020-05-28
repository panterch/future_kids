if Rails.env.production?
  if !(ENV['MAILGUN_SMTP_LOGIN'] && ENV['MAILGUN_SMTP_PASSWORD'] && ENV['APP_DOMAIN'])
    ActionMailer::Base.delivery_method = :sendmail

    ActionMailer::Base.default_url_options = {
      host: 'www.aoz-futurekids.ch',
      protocol: 'https'
    }
  end
else
  ActionMailer::Base.default_url_options = {
    host: 'localhost:3000'
  }
end
