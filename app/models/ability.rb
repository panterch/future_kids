class Ability
  include CanCan::Ability

  def initialize(user)
    if user.is_a?(Admin)
      can :manage, :all
      cannot :create, MentorMatching
    elsif user.is_a?(Mentor)
      # own record may be read
      can [:read, :update, :edit_schedules, :update_schedules, :disable_no_kids_reminder],
          Mentor, id: user.id
      # mentor can read records of admins associated indirectly via kid
      can :read, Admin, coachings: { mentor_id: user.id }
      can :read, Admin, coachings: { secondary_mentor_id: user.id }
      # mentor can read records of other mentors associated indirectly via kid
      can :read, Mentor, kids: { secondary_mentor_id: user.id }
      can :read, Mentor, secondary_kids: { mentor_id: user.id }

      # mentor may be associated via two fields to a kid
      can :read, Kid, mentor_id: user.id, inactive: false
      can :read, Kid, secondary_mentor_id: user.id, secondary_active: true, inactive: false
      if Site.load.public_signups_active?
        if user.sex == 'f'
          can :search, Kid, mentor_id: nil
        else
          can :search, Kid, mentor_id: nil, sex: 'm'
        end
      end

      # journals can be read indirect via kids or direct if they are associated
      # a mentor may read all journal entries with whom he is directly or
      # indirectly (via the kid) associated
      can :read, Journal, mentor_id: user.id
      can :read, Journal, kid: { mentor_id: user.id }
      can :read, Journal, kid: { secondary_mentor_id: user.id,
                                 secondary_active: true }

      # manage - since it is possible for mentors to even destroy journals, the
      # management is defined further below, after the global destroy rules

      # reviews can be edited by mentors who are associated with the kids
      # about whom the entry is
      can :manage, Review, kid: { mentor_id: user.id }
      can :manage, FirstYearAssessment, kid: { mentor_id: user.id }
      can :manage, FirstYearAssessment, kid: { secondary_mentor_id: user.id }
      # has read access to teachers he is connected
      can :read, Teacher, kids: { mentor_id: user.id }
      can :read, Teacher, secondary_kids: { mentor_id: user.id }
      can :read, Teacher, kids: { secondary_mentor_id: user.id,
                                  secondary_active: true }
      can :read, Teacher, secondary_kids: { secondary_mentor_id: user.id,
                                            secondary_active: true }

      # mentor can create mentor_matching
      if Site.load.public_signups_active?
        can :create, MentorMatching, mentor_id: user.id
        can :read, MentorMatching, mentor_id: user.id, state: ['reserved', 'confirmed']
        can [:confirm, :decline], MentorMatching, mentor_id: user.id, state: 'reserved'
      end
    elsif user.is_a?(Teacher)
      can :manage, Teacher, id: user.id
      can :create, Kid
      can [:read, :update], Kid, teacher_id: user.id, inactive: false
      can [:read, :update], Kid, secondary_teacher_id: user.id, inactive: false
      can [:read, :update], Kid, third_teacher_id: user.id, inactive: false
      can :read, Mentor, kids: { teacher_id: user.id }
      can :read, Mentor, kids: { secondary_teacher_id: user.id }
      can :read, Mentor, kids: { third_teacher_id: user.id }
      can :read, Mentor, secondary_kids: { teacher_id: user.id,
                                           secondary_active: true }
      can :read, Mentor, secondary_kids: { secondary_teacher_id: user.id,
                                           secondary_active: true }
      can :read, Mentor, secondary_kids: { third_teacher_id: user.id,
                                           secondary_active: true }

      # journals can be read indirect via kids
      can :read, Journal, kid: { teacher_id: user.id }
      can :read, Journal, kid: { secondary_teacher_id: user.id }
      can :read, Journal, kid: { third_teacher_id: user.id }
      can :manage, TerminationAssessment, kid: { teacher_id: user.id }
      can :manage, TerminationAssessment, kid: { secondary_teacher_id: user.id }
      can :manage, TerminationAssessment, kid: { third_teacher_id: user.id }
      # reviews can only be read for certain instances depending on sitewide config
      if Site.load.teachers_can_access_reviews?
        can :manage, Review, kid: { teacher_id: user.id }
        can :manage, Review, kid: { secondary_teacher_id: user.id }
        can :manage, Review, kid: { third_teacher_id: user.id }
      end

      # mentor matching permissions
      if Site.load.public_signups_active?
        can :manage, MentorMatching, kid: { teacher_id: user.id }
        cannot [:create, :accept, :decline, :confirm], MentorMatching
        can [:accept, :decline], MentorMatching, kid: { teacher_id: user.id }, state: 'pending'
        can :read, Mentor, mentor_matchings: { kid: { teacher_id: user.id } }
      end
    elsif user.is_a?(Principal)
      # own record may be read
      can [:read, :update], Principal, id: user.id
      can :create, Kid
      can [:read, :update], Kid, school_id: user.school_ids
      can :create, Teacher
      can [:read, :update], Teacher, school_id: user.school_ids, inactive: false
    end

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

    # destruction of records is generally not allowed
    cannot :destroy, :all

    # reminders are only created by a batch job, but the destruction is
    # customized in the controller to allow setting the acknowledged_at date
    cannot :create, Reminder
    if user.is_a?(Admin)
      can :destroy, Reminder
      can :destroy, Document
      can :destroy, Journal
      can :destroy, KidMentorRelation
      can :destroy, Review
      can :destroy, FirstYearAssessment
      can :destroy, TerminationAssessment
      can :destroy, Teacher, inactive: true
      can :destroy, Kid, inactive: true
    end

    # special manage definition for mentors - OVERWRITING even the global
    # destroy protection
    if user.is_a?(Mentor)
      # to change a journal there have to be more criterias fulfilled: the mentor
      # himself must be set on the journal entry and must be associated with
      # the kid
      can :manage, Journal, mentor_id: user.id,
                            kid: { mentor_id: user.id }
      can :manage, Journal, mentor_id: user.id,
                            kid: { secondary_mentor_id: user.id,
                                   secondary_active: true }
    end
  end
end
