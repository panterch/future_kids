# frozen_string_literal: true

class Teacher < User
  has_many :kids, dependent: :nullify
  has_many :secondary_kids, class_name: 'Kid',
                            foreign_key: 'secondary_teacher_id', inverse_of: :secondary_teacher,
                            dependent: :nullify
  has_many :third_kids, class_name: 'Kid',
                        foreign_key: 'third_teacher_id', inverse_of: :third_teacher,
                        dependent: :nullify
  has_many :first_year_assessments, dependent: :nullify
  has_many :termination_assessments, dependent: :nullify
  belongs_to :school, optional: true

  before_destroy :release_relations
  after_save :release_relations, if: :inactive?

  def todays_journals(not_before = 1.day.ago)
    journals = (kids.active + secondary_kids.active + third_kids.active).map do |kid|
      kid.journals.where('journals.created_at > ?', not_before)
    end
    journals.flatten.compact
  end

  def self.conditionally_send_journals
    not_before = 1.day.ago
    logger.info "Beginning journal deliver run, refernce time #{not_before}"
    Teacher.active.where(receive_journals: true).find_each do |teacher|
      logger.info "[#{teacher.id}] #{teacher.display_name}: checking journals"
      journals = teacher.todays_journals(not_before)
      if journals.empty?
        logger.info "[#{teacher.id}] #{teacher.display_name}: no new journals"
        next
      end
      logger.info "[#{teacher.id}] #{teacher.display_name}: sending #{journals.size} journals"
      # since this is run async from cron delivery can run instantly
      Notifications.journals_created(teacher, journals).deliver_now
    end
  end

  protected

  # inactive teachers should not be connected to other persons
  def release_relations
    kids.clear
    secondary_kids.clear
    third_kids.clear
  end
end
