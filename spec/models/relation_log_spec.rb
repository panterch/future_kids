require 'spec_helper'

describe RelationLog do
  let(:kid) { create(:kid) }
  let(:mentor) { create(:mentor) }
  let(:teacher) { create(:teacher) }
  let(:admin) { create(:admin) }

  it 'associates mentors' do
    relation_log = create(:relation_log, user: mentor)
    relation_log = RelationLog.find(relation_log.id)
    expect(relation_log.user).to eq(mentor)
  end

  it 'associates teachers' do
    relation_log = create(:relation_log, user: teacher)
    relation_log = RelationLog.find(relation_log.id)
    expect(relation_log.user).to eq(teacher)
  end

  it 'associates coaches' do
    relation_log = create(:relation_log, user: admin)
    relation_log = RelationLog.find(relation_log.id)
    expect(relation_log.user).to eq(admin)
  end

  it 'tracks changing of primary mentor' do
    kid.mentor = mentor
    kid.save!
    expect(kid.relation_logs.count).to eq(1)
    expect(kid.relation_logs.first.user).to eq(mentor)
    expect(kid.relation_logs.first.start_at).not_to be_nil
    expect(kid.relation_logs.first.end_at).to be_nil
    expect(kid.relation_logs.first.role).to eq('mentor')

    kid.mentor = nil
    kid.save!
    expect(kid.relation_logs.count).to eq(2)
    expect(kid.relation_logs.last.user).to eq(mentor)
    expect(kid.relation_logs.last.end_at).not_to be_nil
    expect(kid.relation_logs.last.start_at).to be_nil
    expect(kid.relation_logs.last.role).to eq('mentor')
  end

  it 'tracks changing of secondary mentor' do
    kid.secondary_mentor = mentor
    kid.save!
    expect(kid.relation_logs.count).to eq(1)
    expect(kid.relation_logs.first.user).to eq(mentor)
    expect(kid.relation_logs.first.start_at).not_to be_nil
    expect(kid.relation_logs.first.end_at).to be_nil
    expect(kid.relation_logs.first.role).to eq('secondary_mentor')

    kid.secondary_mentor = nil
    kid.save!
    expect(kid.relation_logs.count).to eq(2)
    expect(kid.relation_logs.last.user).to eq(mentor)
    expect(kid.relation_logs.last.end_at).not_to be_nil
    expect(kid.relation_logs.last.start_at).to be_nil
    expect(kid.relation_logs.last.role).to eq('secondary_mentor')
  end

  it 'tracks changing of teacher' do
    kid.teacher = teacher
    kid.save!
    expect(kid.relation_logs.count).to eq(1)
    expect(kid.relation_logs.first.user).to eq(teacher)
    expect(kid.relation_logs.first.start_at).not_to be_nil
    expect(kid.relation_logs.first.end_at).to be_nil
    expect(kid.relation_logs.first.role).to eq('teacher')

    kid.teacher = nil
    kid.save!
    expect(kid.relation_logs.count).to eq(2)
    expect(kid.relation_logs.last.user).to eq(teacher)
    expect(kid.relation_logs.last.end_at).not_to be_nil
    expect(kid.relation_logs.last.start_at).to be_nil
    expect(kid.relation_logs.last.role).to eq('teacher')
  end

  it 'tracks changing of secondary teacher' do
    kid.secondary_teacher = teacher
    kid.save!
    expect(kid.relation_logs.count).to eq(1)
    expect(kid.relation_logs.first.user).to eq(teacher)
    expect(kid.relation_logs.first.start_at).not_to be_nil
    expect(kid.relation_logs.first.end_at).to be_nil
    expect(kid.relation_logs.first.role).to eq('secondary_teacher')

    kid.secondary_teacher = nil
    kid.save!
    expect(kid.relation_logs.count).to eq(2)
    expect(kid.relation_logs.last.user).to eq(teacher)
    expect(kid.relation_logs.last.end_at).not_to be_nil
    expect(kid.relation_logs.last.start_at).to be_nil
    expect(kid.relation_logs.last.role).to eq('secondary_teacher')
  end

  it 'tracks changing of coach' do
    kid.admin = admin
    kid.save!
    expect(kid.relation_logs.count).to eq(1)
    expect(kid.relation_logs.first.user).to eq(admin)
    expect(kid.relation_logs.first.start_at).not_to be_nil
    expect(kid.relation_logs.first.end_at).to be_nil
    expect(kid.relation_logs.first.role).to eq('admin')

    kid.admin = nil
    kid.save!
    expect(kid.relation_logs.count).to eq(2)
    expect(kid.relation_logs.last.user).to eq(admin)
    expect(kid.relation_logs.last.end_at).not_to be_nil
    expect(kid.relation_logs.last.start_at).to be_nil
    expect(kid.relation_logs.last.role).to eq('admin')
  end

  it 'tracks changing more than one relation at once' do
    kid.admin = admin
    kid.mentor = mentor
    kid.teacher = teacher
    kid.save!

    expect(kid.relation_logs.count).to eq(3)
  end

  it 'tracks breaking up relations when new value is given' do
    kid.mentor = mentor
    kid.save!
    other_mentor = create(:mentor)
    kid.mentor = other_mentor
    kid.save!

    expect(kid.relation_logs.count).to eq(3)

    expect(kid.relation_logs.map(&:user).sort).to eq(
      [other_mentor, mentor, mentor].sort
    )
  end
end
