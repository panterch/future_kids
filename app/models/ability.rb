# frozen_string_literal: true

class Ability
  include CanCan::Ability

  # rules are purely additive: each role method grants exactly the actions it
  # is meant to have, so no rule depends on being revoked later. grant
  # :manage only in admin_abilities - everywhere else list the actions
  # explicitly, otherwise destroy would be granted unintentionally
  def initialize(user)
    role_abilities(user)
    common_abilities(user)
  end

  private

  def role_abilities(user)
    case user
    when Admin then admin_abilities(user)
    when Mentor then mentor_abilities(user)
    when Teacher then teacher_abilities(user)
    when Principal then principal_abilities(user)
    end
  end

  def admin_abilities(_user)
    can :manage, :all

    # destruction of records is generally not allowed and must be granted
    # per model below - new models are not destroyable by default. cancancan
    # gives later rules precedence, so keep these revocations adjacent to
    # the :manage grant above
    cannot :destroy, :all
    can :destroy, Reminder
    can :destroy, Document
    can :destroy, Journal
    can :destroy, KidMentorRelation
    can :destroy, Review
    can :destroy, FirstYearAssessment
    can :destroy, TerminationAssessment
    can :destroy, Teacher, inactive: true
    can :destroy, Kid, inactive: true

    # reminders are only created by a batch job, but the destruction is
    # customized in the controller to allow setting the acknowledged_at date
    cannot :create, Reminder
  end

  def mentor_abilities(user)
    # own record may be read
    can %i[read update edit_schedules update_schedules], Mentor, id: user.id
    # mentor can read records of admins associated indirectly via kid
    can :read, Admin, coachings: { mentor_id: user.id }
    can :read, Admin, coachings: { secondary_mentor_id: user.id }
    # mentor can read records of other mentors associated indirectly via kid
    can :read, Mentor, kids: { secondary_mentor_id: user.id, secondary_active: true }
    can :read, Mentor, secondary_kids: { mentor_id: user.id, secondary_active: true }

    # mentor may be associated via two fields to a kid
    can :read, Kid, mentor_id: user.id, inactive: false
    can :read, Kid, secondary_mentor_id: user.id, secondary_active: true, inactive: false
    # journals can be read indirect via kids or direct if they are associated
    # a mentor may read all journal entries with whom he is directly or
    # indirectly (via the kid) associated
    can :read, Journal, mentor_id: user.id
    can :read, Journal, kid: { mentor_id: user.id }
    can :read, Journal, kid: { secondary_mentor_id: user.id, secondary_active: true }

    # to change a journal there have to be more criterias fulfilled: the
    # mentor himself must be set on the journal entry and must be associated
    # with the kid. these are the only rules besides the admin ones that
    # grant destroy
    can %i[create read update destroy], Journal, mentor_id: user.id, kid: { mentor_id: user.id }
    can %i[create read update destroy], Journal,
        mentor_id: user.id, kid: { secondary_mentor_id: user.id, secondary_active: true }

    # reviews can be edited by mentors who are associated with the kids
    # about whom the entry is
    can %i[create read update], Review, kid: { mentor_id: user.id }
    can %i[create read update], FirstYearAssessment, kid: { mentor_id: user.id }
    can %i[create read update], FirstYearAssessment,
        kid: { secondary_mentor_id: user.id, secondary_active: true }
    # has read access to teachers he is connected
    can :read, Teacher, kids: { mentor_id: user.id }
    can :read, Teacher, secondary_kids: { mentor_id: user.id }
    can :read, Teacher, kids: { secondary_mentor_id: user.id, secondary_active: true }
    can :read, Teacher, secondary_kids: { secondary_mentor_id: user.id, secondary_active: true }
  end

  def teacher_abilities(user)
    # own record may be read and updated
    can %i[read update], Teacher, id: user.id
    can :create, Kid
    can %i[read update], Kid, teacher_id: user.id, inactive: false
    can %i[read update], Kid, secondary_teacher_id: user.id, inactive: false
    can %i[read update], Kid, third_teacher_id: user.id, inactive: false
    can :read, Mentor, kids: { teacher_id: user.id }
    can :read, Mentor, kids: { secondary_teacher_id: user.id }
    can :read, Mentor, kids: { third_teacher_id: user.id }
    can :read, Mentor, secondary_kids: { teacher_id: user.id, secondary_active: true }
    can :read, Mentor, secondary_kids: { secondary_teacher_id: user.id, secondary_active: true }
    can :read, Mentor, secondary_kids: { third_teacher_id: user.id, secondary_active: true }

    # journals can be read indirect via kids
    can :read, Journal, kid: { teacher_id: user.id }
    can :read, Journal, kid: { secondary_teacher_id: user.id }
    can :read, Journal, kid: { third_teacher_id: user.id }
    can %i[create read update], TerminationAssessment, kid: { teacher_id: user.id }
    can %i[create read update], TerminationAssessment, kid: { secondary_teacher_id: user.id }
    can %i[create read update], TerminationAssessment, kid: { third_teacher_id: user.id }
    # reviews can only be read for certain instances depending on sitewide config
    return unless Site.load.teachers_can_access_reviews?

    can %i[create read update], Review, kid: { teacher_id: user.id }
    can %i[create read update], Review, kid: { secondary_teacher_id: user.id }
    can %i[create read update], Review, kid: { third_teacher_id: user.id }
  end

  def principal_abilities(user)
    # own record may be read
    can %i[read update], Principal, id: user.id
    can :create, Kid
    can %i[read update], Kid, school_id: user.school_ids
    can :create, Teacher
    can %i[read update], Teacher, school_id: user.school_ids, inactive: false
    can :read, Journal, kid: { school_id: user.school_ids }
  end

  def common_abilities(user)
    # comments can be created by any users that can access the journal
    # this is protected via the controller
    # reading is only possible via the kids show action which is protected
    # and updating is only possible for the user that created the comment
    can :create, Comment, created_by_id: user.id
    can :update, Comment, created_by_id: user.id

    # some documents are admin only
    if user.is_a?(Admin)
      can :read, Document
    else
      can :read, Document, admin_only: false
    end
  end
end
