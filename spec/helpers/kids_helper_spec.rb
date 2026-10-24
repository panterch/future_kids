# frozen_string_literal: true

require 'spec_helper'

describe KidsHelper do
  describe 'goal layout' do
    def goals_of(card)
      card.flat_map(&:last)
    end

    # Each card only lays out its own Kid::GOAL_CARDS goals -- a goal shown
    # under the wrong card (or missing entirely) would still count towards
    # that card's min/max validation but be displayed in the wrong place.
    KidsHelper::SUBJECT_GOAL_CARDS.merge(KidsHelper::GENERAL_GOAL_CARDS).each do |key, card|
      it "lays out exactly #{key}'s goals" do
        expect(goals_of(card)).to match_array(Kid::GOAL_CARDS.fetch(key)[:goals])
      end
    end
  end
end
