require 'spec_helper'

describe ApplicationController do

  let!(:mentor) { create(:mentor, sex: 'f') }
  let!(:kid) { create(:kid, sex: 'f') }
  let!(:kid2) { create(:kid, sex: 'f') }
  let!(:mentor_with_kids) { create(:mentor, sex: 'f', kids: [kid]) }

  let!(:pending_mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid, state: 'pending') }
  let!(:reserved_mentor_matching) { create(:mentor_matching, mentor: mentor, kid: kid2, state: 'reserved') }
  let!(:teacher_with_pending_matchings) { create(:teacher, kids: [kid]) }
  let!(:teacher_without_pending_matchings) { create(:teacher, kids: [kid2]) }

  context 'public signups enabled' do
    before do
      Site.load.update!(kids_schedule_hourly: false, public_signups_active: true)
    end

    it 'mentor with kids' do
      sign_in mentor

      expect(subject.after_sign_in_path_for(nil)).to eq(available_kids_path)
    end

    it 'mentor without kids' do
      sign_in mentor_with_kids
      expect(subject.after_sign_in_path_for(nil)).to eq(root_path)
    end

    it 'teacher with pending matchings' do
      sign_in teacher_with_pending_matchings
      expect(subject.after_sign_in_path_for(nil)).to eq(mentor_matchings_path)
    end

    it 'teacher without pending matchings' do
      sign_in teacher_without_pending_matchings
      expect(subject.after_sign_in_path_for(nil)).to eq(root_path)
    end
  end

  context 'public signups disabled' do
    before do
      Site.load.update!(kids_schedule_hourly: false, public_signups_active: false)
    end

    it 'mentor with kids' do
      sign_in mentor

      expect(subject.after_sign_in_path_for(nil)).to eq(root_path)
    end

    it 'mentor without kids' do
      sign_in mentor_with_kids
      expect(subject.after_sign_in_path_for(nil)).to eq(root_path)
    end

    it 'teacher with pending matchings' do
      sign_in teacher_with_pending_matchings
      expect(subject.after_sign_in_path_for(nil)).to eq(root_path)
    end

    it 'teacher without pending matchings' do
      sign_in teacher_without_pending_matchings
      expect(subject.after_sign_in_path_for(nil)).to eq(root_path)
    end
  end
end
