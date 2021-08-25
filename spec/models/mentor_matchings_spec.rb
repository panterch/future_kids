require 'spec_helper'

describe MentorMatching do
  context 'confirmed' do
    let(:mentor) { create(:mentor, sex: 'm') }
    let(:other_mentor) { create(:mentor, sex: 'm') }
    let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', teacher: create(:teacher)) }
    let!(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'reserved') }
    let!(:other_mentor_matching) { create(:mentor_matching, mentor: other_mentor, kid: kid, state: 'pending') }

    it 'confirms matching and declines others' do
      # one email is to teacher with confirmation info, other email is to other_mentor with declined
      expect{ mentor_matching.confirmed }.to change { change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(2) }

      expect(mentor_matching.reload.state).to eq 'confirmed'
      expect(other_mentor_matching.reload.state).to eq 'declined'
      expect(kid.reload.mentor).to eq mentor
    end
  end

  context 'declined' do
    let(:mentor) { create(:mentor, sex: 'm') }
    let(:other_mentor) { create(:mentor, sex: 'm') }
    let(:kid) { create(:kid, name: 'Hodler Rolf', sex: 'm', teacher: create(:teacher)) }
    let!(:mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'reserved') }
    let!(:other_mentor_matching) { create(:mentor_matching, mentor: other_mentor, kid: kid, state: 'pending') }

    it 'declines matching' do
      expect{ mentor_matching.declined }.to change { change { ActiveJob::Base.queue_adapter.enqueued_jobs.count }.by(1) }

      expect(mentor_matching.reload.state).to eq 'declined'
      expect(other_mentor_matching.reload.state).to eq 'pending'
      expect(kid.reload.mentor).to eq nil
    end
  end
end
