class Teacher < User
  has_many :kids
  has_many :secondary_kids, class_name: 'Kid',
                            foreign_key: 'secondary_teacher_id'
  belongs_to :school

  after_save :release_relations, if: :inactive?

  def todays_journals(not_before = Time.now - 1.day)
    journals = []
    (kids.active + secondary_kids.active).each do |kid|
      journals << kid.journals.where('journals.created_at > ?', not_before)
    end
    journals.flatten.compact
  end

  def self.conditionally_send_journals
    not_before = Time.now - 1.day
    logger.info "Beginning journal deliver run, refernce time #{not_before}"
    Teacher.active.where(receive_journals: true).find_each do |teacher|
      logger.info "[#{teacher.id}] #{teacher.display_name}: checking journals"
      journals = teacher.todays_journals(not_before)
      if journals.empty?
        logger.info "[#{teacher.id}] #{teacher.display_name}: no new journals"
        next
      end
      logger.info "[#{teacher.id}] #{teacher.display_name}: sending #{journals.size} journals"
      Notifications.journals_created(teacher, journals).deliver_now
    end
  end

  protected

  # inactive mentors should not be connected to other persons
  def release_relations
    kids.clear
    secondary_kids.clear
  end
end
