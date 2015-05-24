class Site < ActiveRecord::Base
  has_attached_file :logo,
                    styles: { medium: ['440>', :png] },
                    default_url: '/images/:style/default_logo.png',
                    path: ':rails_root/public/system/:attachment/:id/:style/:filename',
                    url: '/system/:attachment/:id/:style/:filename'

  validates_attachment_content_type :logo, content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif']
end
