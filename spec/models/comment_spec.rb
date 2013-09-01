require 'spec_helper'

describe Comment do

  context "default values from last journal comment" do
    before do
      @previous = Factory(:comment)
      @journal = @previous.journal
      @comment = @journal.comments.build
    end

    it "determines the previous entry" do
      @comment.previous_comment.should eq(@previous)
    end

    it "does not set recipients when not present on previous" do
      @comment.initialize_default_values(@journal.mentor)
      @comment.to_teacher.should eq(false)
      @comment.to_secondary_teacher.should eq(false)
    end

    it "does set recipients from previous" do
      @previous.update_attributes(:to_teacher => true,
                                  :to_secondary_teacher => true)
      @comment.initialize_default_values(@journal.mentor)
      @comment.to_teacher.should eq(true)
      @comment.to_secondary_teacher.should eq(true)
    end

    it "does set teacher as recipient when creator" do
      @journal.kid.update_attribute(:teacher, Factory(:teacher))
      @comment.initialize_default_values(@journal.kid.teacher)
      @comment.to_teacher.should eq(true)
      @comment.to_secondary_teacher.should eq(false)
    end
  end

  context "recipients" do
    before do
      @comment = Factory(:comment)
      @kid = @comment.journal.kid
      @kid.update_attribute(:mentor, @comment.journal.mentor)
    end
    it "is the mentor" do
      @comment.recipients.should eq([@kid.mentor.email])
    end
    it "add the coach when present" do
      @coach = Factory(:admin)
      @kid.update_attribute(:admin, @coach)
      @comment.recipients.should eq([@kid.mentor.email, @coach.email])
    end
    it "adds the teachers if requested" do
      @kid.update_attribute(:teacher, @teacher1 = Factory(:teacher))
      @kid.update_attribute(:secondary_teacher,
                            @teacher2 = Factory(:teacher))
      @comment.update_attributes(:to_teacher => true,
                                 :to_secondary_teacher => true)
      @comment.recipients.should eq([@kid.mentor.email,
                                     @teacher1.email, @teacher2.email])
    end
    it "does not add present teacher if not requested" do
      @kid.update_attribute(:teacher, Factory(:teacher))
      @kid.update_attribute(:secondary_teacher, Factory(:teacher))
      @comment.recipients.should eq([@kid.mentor.email])
    end
  end
end
