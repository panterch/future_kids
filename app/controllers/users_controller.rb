class UsersController < ApplicationController

  def edit_terms
    if !current_user.nil?
      current_user.update(terms_of_use_accepted: true, terms_of_use_accepted_date: DateTime.now)
    end

    if current_user.is_a?(Mentor) && current_user.kids.empty?
      # if a menotr has no kids yet assigned, go to available kids
      redirect_to available_kids_path
    elsif current_user.is_a?(Teacher) && current_user.mentor_matchings.pluck(:state).include?('pending')
      # if teacher has some pending requests from mentors
      redirect_to mentor_matchings_path
    else
      redirect_to root_path
    end
  end
end