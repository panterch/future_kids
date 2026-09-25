# frozen_string_literal: true

require 'spec_helper'

describe KidsHelper do
  describe 'goal layout' do
    def goals_of(cards)
      cards.values.flatten(1).flat_map(&:last)
    end

    # The cards only lay out Kid's goal fields -- a goal missing here would
    # still count towards the GOALS_*_MAX validation but never be shown.
    it 'lays out exactly the subject goals' do
      expect(goals_of(KidsHelper::SUBJECT_GOAL_CARDS)).to match_array(Kid::GOALS_1)
    end

    it 'lays out exactly the general goals' do
      expect(goals_of(KidsHelper::GENERAL_GOAL_CARDS)).to match_array(Kid::GOALS_2)
    end
  end
end
