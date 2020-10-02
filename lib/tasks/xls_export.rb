filename = 'future_kids.' + Time.now.strftime("%Y-%m-%d_%H-%M-%S") + '.xlsx'

view_assigns = {kids: Kid.all, mentors: Mentor.all, kid_mentor_relations: KidMentorRelation.all}
av = ActionView::Base.new(ActionController::Base.view_paths, view_assigns)
av.class_eval do
  # include any needed helpers (for the view)
  include ApplicationHelper
end

content = av.render template: 'sites/show.xlsx.axlsx'
File.write(File.join('tmp', filename), content)

require 'net/sftp'
Net::SFTP.start(ENV['SFTP_HOST'], ENV['SFTP_USER'], password: ENV['SFTP_PASS']) do |sftp|
  sftp.upload!(File.join('tmp', filename), filename)
end


