class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    if user.is_a?(Admin)
      can :manage, :all
    elsif user.is_a?(Mentor)
      # own record may be read
      can [ :read, :update ],   Mentor, :id => user.id

      # mentor may be associated via two fields to a kid
      can :read, Kid, :mentor_id => user.id
      can :read, Kid, :secondary_mentor_id => user.id

      # journals can be read indirect via kids or direct if they are associated
      # a mentor may read all journal entries with whom he is directly or
      # indirectly (via the kid) associated
      can :read, Journal, :mentor_id => user.id
      can :read, Journal, :kid => { :mentor_id => user.id }
      can :read, Journal, :kid => { :secondary_mentor_id => user.id }
      # to change an entry there have to be more criterias fulfilled: the mentor
      # himself must be set on the journal entry and must be associated with
      # the kid
      can :manage, Journal, :mentor_id => user.id,
                            :kid => { :mentor_id => user.id }
      can :manage, Journal, :mentor_id => user.id,
                            :kid => { :secondary_mentor_id => user.id }

      # reviews can be edited by mentors who are associated with the kids
      # about whom the entry is
      can :manage, Review, :kid => { :mentor_id => user.id }
      can :manage, Review, :kid => { :secondary_mentor_id => user.id }
    elsif user.is_a?(Teacher)
      can :manage, Teacher, :id => user.id
      can :read, Kid, :teacher_id => user.id
      can :read, Kid, :secondary_teacher_id => user.id
      can :read, Mentor, :kids => { :teacher_id => user.id }
      can :read, Mentor, :kids => { :secondary_teacher_id => user.id }
      can :read, Mentor, :secondary_kids => { :teacher_id => user.id }
      can :read, Mentor, :secondary_kids => { :secondary_teacher_id => user.id }
    end

    # destruction of records is generally not allowed
    cannot :destroy, :all

    # reminders are only created by a batch job
    cannot :create, Reminder
  end
end



