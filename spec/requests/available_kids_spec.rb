require 'requests/acceptance_helper'

describe 'AvailableKids' do
  before do
    Site.load.update!(kids_schedule_hourly: false, public_signups_active: true)
    create(:kid, name: 'Hodler Rolf', sex: 'm', grade: '1').update!(longitude: 14.1025379, latitude: 50.1478497)
    create(:kid, name: 'Maria Rolf', sex: 'f', grade: '5').update!(longitude: 14.1025379, latitude: 50.1478497)
    create(:kid, name: 'Olivia Rolf', sex: 'f', grade: '5').update!(longitude: 14.0474263, latitude: 50.1873213)
  end

  context 'AvailableKids as Mentor' do
    before do
      @mentor = create(:mentor)
      @mentor.update!(longitude: 14.0474263, latitude: 50.1873213)
      log_in(@mentor)
    end

    describe 'Available kids for men' do
      before do
        @mentor.update(sex: 'm')
        visit available_kids_path
      end

      scenario 'mentor can see one kid' do
        expect(page).to have_content('Hodler Rolf')
        expect(page).not_to have_content('Maria Rolf')
        expect(page).to have_content('5.89 km')
        expect(page).to have_content('Lehrperson anschreiben')
      end
    end

    describe 'Available kids for women' do
      before do
        @mentor.update(sex: 'f')
        visit available_kids_path
      end

      scenario 'mentor can see two kids' do
        expect(page).to have_content('Hodler Rolf')
        expect(page).to have_content('Maria Rolf')
        expect(page).to have_content('5.89 km')
      end
    end

    describe 'Available kids actions' do
      before do
        @mentor.update!(sex: 'm')
        visit available_kids_path
        click_link('Lehrperson anschreiben')
        fill_in 'Nachricht', with: 'I want to mentor the kid'
        click_button('Mentoring Anfrage erstellen')
        visit available_kids_path
      end

      scenario 'mentor can see mentor matching state' do
        # create action
        expect(page).to have_content('Lehrperson angeschrieben')
        @mentor.mentor_matchings.last.reserved!
        visit available_kids_path
        # confirm, decline, show actions
        expect(page).to have_content(I18n.t(:show, scope: 'crud.action'))
        expect(page).to have_content(I18n.t(:confirm, scope: 'crud.action'))
        expect(page).to have_content(I18n.t(:decline, scope: 'crud.action'))
        @mentor.mentor_matchings.last.confirmed!
        visit available_kids_path
        # only show action
        expect(page).to have_content(I18n.t(:show, scope: 'crud.action'))
        expect(page).not_to have_content(I18n.t(:confirm, scope: 'crud.action'))
        expect(page).not_to have_content(I18n.t(:decline, scope: 'crud.action'))
      end

      scenario 'mentor can show matching' do
        @mentor.mentor_matchings.last.reserved!
        visit available_kids_path
        click_link(I18n.t(:show, scope: 'crud.action'))
        expect(page).to have_content('Hodler Rolf')
      end

      scenario 'mentor can confirm matching' do
        mentor_matching = @mentor.mentor_matchings.last
        mentor_matching.reserved!
        visit available_kids_path
        expect {
          click_link(I18n.t(:confirm, scope: 'crud.action'))
        }.to change { mentor_matching.reload.state }.from('reserved').to('confirmed')
      end

      scenario 'mentor can decline matching' do
        mentor_matching = @mentor.mentor_matchings.last
        mentor_matching.reserved!
        visit available_kids_path
        expect {
          click_link(I18n.t(:decline, scope: 'crud.action'))
        }.to change { mentor_matching.reload.state }.from('reserved').to('declined')
      end
    end

    describe 'Available kids for filter grade_group', js: true do
      before do
        @mentor.update!(sex: 'f')
        visit available_kids_path
      end

      scenario 'mentor can see one kid with grade 1' do
        select('Unterstufe', from: 'grade_group')
        expect(page).to have_content('Hodler Rolf')
        expect(page).not_to have_content('Maria Rolf')
      end

      scenario 'mentor can see one kid with grade 5' do
        select('Mittelstufe', from: 'grade_group')
        expect(page).not_to have_content('Hodler Rolf')
        expect(page).to have_content('Maria Rolf')
      end
    end

    describe 'Available kids for filter distance_from', js: true do
      before do
        @mentor.update(sex: 'f')
        visit available_kids_path
      end

      scenario 'can see distance_from him' do
        select('Mentor', from: 'distance_from')
        expect(page).to have_content('5.89 km')
      end

      scenario 'can see distance_from Zurich HB' do
        select('Zürich HB', from: 'distance_from')
        expect(page).to have_content('511.19 km')
      end
    end

    describe 'Available kids with order_by', js: true do
      before do
        @mentor.update(sex: 'f')
        visit available_kids_path
      end

      scenario 'can see kids ordered by distance' do
        select('Entfernung', from: 'order_by')
        expect(page.body.index('0 km') < page.body.index('5.89 km')).to eq true
      end
    end
  end

  context 'as Admin' do

    describe 'Available kids' do
      before do
        log_in(create(:admin))
        visit available_kids_path
      end

      scenario 'admin cannot create mentor matching' do
        expect(page).to have_content('Hodler Rolf')
        expect(page).not_to have_content('Lehrperson anschreiben')
      end
    end
  end

  context 'as Teacher' do

    describe 'Available kids' do
      before do
        log_in(create(:teacher))
        visit available_kids_path
      end

      scenario 'teacher cannot create mentor matching' do
        expect(page).not_to have_content('Lehrperson anschreiben')
      end
    end
  end
end
