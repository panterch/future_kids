require 'spec_helper'

describe RelationLog do
  let(:kid) { Factory(:kid) }
  let(:mentor) { Factory(:mentor) }
  let(:teacher) { Factory(:teacher) }
  let(:admin) { Factory(:admin) }

  it 'associates mentors' do
    relation_log = Factory(:relation_log, :user => mentor)
    relation_log = RelationLog.find(relation_log.id)
    relation_log.user.should eq(mentor)
  end

  it 'associates teachers' do
    relation_log = Factory(:relation_log, :user => teacher)
    relation_log = RelationLog.find(relation_log.id)
    relation_log.user.should eq(teacher)
  end

  it 'associates coaches' do
    relation_log = Factory(:relation_log, :user => admin)
    relation_log = RelationLog.find(relation_log.id)
    relation_log.user.should eq(admin)
  end

  it 'tracks changing of primary mentor' do
    kid.mentor = mentor
    kid.save!
    kid.relation_logs.count.should eq(1)
    kid.relation_logs.first.user.should eq(mentor)
    kid.relation_logs.first.start_at.should_not be_nil
    kid.relation_logs.first.end_at.should be_nil
    kid.relation_logs.first.role.should eq('mentor')

    kid.mentor = nil
    kid.save!
    kid.relation_logs.count.should eq(2)
    kid.relation_logs.last.user.should eq(mentor)
    kid.relation_logs.last.end_at.should_not be_nil
    kid.relation_logs.last.start_at.should be_nil
    kid.relation_logs.last.role.should eq('mentor')
  end

  it 'tracks changing of secondary mentor' do
    kid.secondary_mentor = mentor
    kid.save!
    kid.relation_logs.count.should eq(1)
    kid.relation_logs.first.user.should eq(mentor)
    kid.relation_logs.first.start_at.should_not be_nil
    kid.relation_logs.first.end_at.should be_nil
    kid.relation_logs.first.role.should eq('secondary_mentor')

    kid.secondary_mentor = nil
    kid.save!
    kid.relation_logs.count.should eq(2)
    kid.relation_logs.last.user.should eq(mentor)
    kid.relation_logs.last.end_at.should_not be_nil
    kid.relation_logs.last.start_at.should be_nil
    kid.relation_logs.last.role.should eq('secondary_mentor')
  end

  it 'tracks changing of teacher' do
    kid.teacher = teacher
    kid.save!
    kid.relation_logs.count.should eq(1)
    kid.relation_logs.first.user.should eq(teacher)
    kid.relation_logs.first.start_at.should_not be_nil
    kid.relation_logs.first.end_at.should be_nil
    kid.relation_logs.first.role.should eq('teacher')

    kid.teacher = nil
    kid.save!
    kid.relation_logs.count.should eq(2)
    kid.relation_logs.last.user.should eq(teacher)
    kid.relation_logs.last.end_at.should_not be_nil
    kid.relation_logs.last.start_at.should be_nil
    kid.relation_logs.last.role.should eq('teacher')
  end

  it 'tracks changing of secondary teacher' do
    kid.secondary_teacher = teacher
    kid.save!
    kid.relation_logs.count.should eq(1)
    kid.relation_logs.first.user.should eq(teacher)
    kid.relation_logs.first.start_at.should_not be_nil
    kid.relation_logs.first.end_at.should be_nil
    kid.relation_logs.first.role.should eq('secondary_teacher')

    kid.secondary_teacher = nil
    kid.save!
    kid.relation_logs.count.should eq(2)
    kid.relation_logs.last.user.should eq(teacher)
    kid.relation_logs.last.end_at.should_not be_nil
    kid.relation_logs.last.start_at.should be_nil
    kid.relation_logs.last.role.should eq('secondary_teacher')
  end

  it 'tracks changing of coach' do
    kid.admin = admin
    kid.save!
    kid.relation_logs.count.should eq(1)
    kid.relation_logs.first.user.should eq(admin)
    kid.relation_logs.first.start_at.should_not be_nil
    kid.relation_logs.first.end_at.should be_nil
    kid.relation_logs.first.role.should eq('admin')

    kid.admin = nil
    kid.save!
    kid.relation_logs.count.should eq(2)
    kid.relation_logs.last.user.should eq(admin)
    kid.relation_logs.last.end_at.should_not be_nil
    kid.relation_logs.last.start_at.should be_nil
    kid.relation_logs.last.role.should eq('admin')
  end

  it 'tracks changing more than one relation at once' do
    kid.admin = admin
    kid.mentor = mentor
    kid.teacher = teacher
    kid.save!

    kid.relation_logs.count.should eq(3)
  end

  it 'tracks breaking up relations when new value is given' do
    kid.mentor = mentor
    kid.save!
    other_mentor = Factory(:mentor)
    kid.mentor = other_mentor
    kid.save!

    kid.relation_logs.count.should eq(3)

    kid.relation_logs.first.user.should eq(other_mentor)
    kid.relation_logs.second.user.should eq(mentor)
    kid.relation_logs.last.user.should eq(mentor)
  end
end
