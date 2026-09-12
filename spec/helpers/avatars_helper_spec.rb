# frozen_string_literal: true

require 'spec_helper'

describe AvatarsHelper do
  describe '#avatar' do
    it 'returns an empty string for a blank resource' do
      expect(helper.avatar(nil)).to eq('')
    end

    it 'renders initials on a type-colored background when there is no photo' do
      teacher = build(:teacher, name: 'Muster', prename: 'Hans')

      markup = helper.avatar(teacher)

      expect(markup).to have_css('span.avatar.avatar-md.avatar-teacher')
      expect(markup).to have_css('span.avatar-initials[aria-hidden="true"]', text: 'HM')
      expect(markup).not_to have_css('img')
    end

    it 'falls back to two letters of the name when there is no prename' do
      kid = build(:kid, name: 'Muster', prename: nil)

      expect(helper.avatar(kid)).to have_css('span.avatar-initials', text: 'MU')
    end

    it 'renders the photo, marked as a real photo, when one is attached' do
      mentor = create(:mentor)

      markup = helper.avatar(mentor)

      expect(markup).to have_css('span.avatar.avatar-mentor.avatar-photo')
      expect(markup).to have_css("img.avatar-img[alt='#{mentor.display_name}']")
    end

    it 'uses the small photo_thumb variant for sm/md, and the original upload for lg' do
      mentor = create(:mentor)

      expect(helper.avatar(mentor, size: :md)).to have_css("img[src='#{helper.rails_representation_url(mentor.photo_thumb)}']")
      expect(helper.avatar(mentor, size: :lg)).to have_css("img[src='#{helper.rails_blob_path(mentor.photo)}']")
    end

    it 'keys the color to the resource type' do
      expect(helper.avatar(create(:mentor))).to have_css('.avatar-mentor')
      expect(helper.avatar(build(:teacher))).to have_css('.avatar-teacher')
      expect(helper.avatar(build(:admin))).to have_css('.avatar-admin')
      expect(helper.avatar(build(:principal))).to have_css('.avatar-principal')
      expect(helper.avatar(build(:kid))).to have_css('.avatar-kid')
    end
  end

  describe '#avatar_link_to' do
    it 'returns an empty string for a blank resource' do
      expect(helper.avatar_link_to(nil)).to eq('')
    end

    it 'combines the avatar with can_link_to\'s linked name' do
      kid = create(:kid)
      allow(helper).to receive(:cannot?).and_return(false)

      markup = helper.avatar_link_to(kid)

      expect(markup).to have_css('span.avatar-link')
      expect(markup).to have_css('.avatar')
      expect(markup).to have_link(kid.display_name)
    end

    it 'renders the plain display name (no link) without read access' do
      kid = create(:kid)
      allow(helper).to receive(:cannot?).and_return(true)

      markup = helper.avatar_link_to(kid)

      expect(markup).to have_text(kid.display_name)
      expect(markup).not_to have_link(kid.display_name)
    end
  end

  describe '#profile_photo' do
    it 'returns an empty string for a blank resource' do
      expect(helper.profile_photo(nil)).to eq('')
    end

    it 'renders the full, uncropped photo when one is attached' do
      mentor = create(:mentor)

      markup = helper.profile_photo(mentor)

      expect(markup).to have_css('div.profile-portrait img.profile-portrait-img')
      expect(markup).not_to have_css('.avatar')
    end

    it 'falls back to the regular :lg avatar when there is no photo' do
      teacher = build(:teacher)

      markup = helper.profile_photo(teacher)

      expect(markup).to have_css('.avatar.avatar-lg')
      expect(markup).not_to have_css('.profile-portrait')
    end
  end
end
