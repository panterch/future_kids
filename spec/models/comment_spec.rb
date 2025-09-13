require 'spec_helper'

describe Comment do
  context 'default values from last journal comment' do
    before do
      @previous = create(:comment)
      @journal = @previous.journal
      @comment = @journal.comments.build
    end

    it 'determines the previous entry' do
      expect(@comment.previous_comment).to eq(@previous)
    end

    it 'does not set recipients when not present on previous' do
      @comment.initialize_default_values(@journal.mentor)
      expect(@comment.to_teacher).to eq(false)
      expect(@comment.to_secondary_teacher).to eq(false)
    end

    it 'does set recipients from previous' do
      @previous.update(to_teacher: true,
                       to_secondary_teacher: true)
      @comment.initialize_default_values(@journal.mentor)
      expect(@comment.to_teacher).to eq(true)
      expect(@comment.to_secondary_teacher).to eq(true)
    end

    it 'does set teacher as recipient when creator' do
      @journal.kid.update_attribute(:teacher, create(:teacher))
      @comment.initialize_default_values(@journal.kid.teacher)
      expect(@comment.to_teacher).to eq(true)
      expect(@comment.to_secondary_teacher).to eq(false)
    end
  end

  context 'recipients' do
    before do
      @comment = create(:comment)
      @kid = @comment.journal.kid
      @kid.update_attribute(:mentor, @comment.journal.mentor)
    end

    it 'is the mentor' do
      expect(@comment.recipients).to eq([@kid.mentor.email])
    end

    it 'is not the mentor when he is the sender' do
      @comment.created_by = @kid.mentor
      expect(@comment.recipients).not_to include(@kid.mentor.email)
    end

    it 'add the coach when present' do
      @coach = create(:admin)
      @kid.update_attribute(:admin, @coach)
      expect(@comment.recipients).to eq([@kid.mentor.email, @coach.email])
    end

    it 'adds the teachers if requested' do
      @kid.update_attribute(:teacher, @teacher1 = create(:teacher))
      @kid.update_attribute(:secondary_teacher,
                            @teacher2 = create(:teacher))
      @comment.update(to_teacher: true,
                      to_secondary_teacher: true)
      expect(@comment.recipients).to eq([@kid.mentor.email,
                                         @teacher1.email, @teacher2.email])
    end

    it 'does not add present teacher if not requested' do
      @kid.update_attribute(:teacher, create(:teacher))
      @kid.update_attribute(:secondary_teacher, create(:teacher))
      expect(@comment.recipients).to eq([@kid.mentor.email])
    end
  end
end
