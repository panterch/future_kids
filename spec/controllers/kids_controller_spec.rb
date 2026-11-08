# frozen_string_literal: true

require 'spec_helper'

describe KidsController do
  context 'as a mentor' do
    before do
      @mentor = create(:mentor)
      @kid = create(:kid, mentor: @mentor)
      sign_in @mentor
    end

    context 'index' do
      it 'renders' do
        get :index
        expect(response).to be_successful
        expect(assigns(:kids).length).to eq(1)
      end
    end

    context 'schedules' do
      it 'does not allow displaying the kids schedule' do
        expect_access_denied { get :edit_schedules, params: { id: @kid } }
      end

      it 'does not allow updating the kids schedule' do
        expect_access_denied { post :update_schedules, params: { id: @kid } }
      end
    end

    context 'markdown' do
      it 'does not allow rendering the markdown representation' do
        expect_access_denied { get :show, params: { id: @kid }, format: :md }
      end

      it 'does not allow rendering the redacted markdown representation' do
        expect_access_denied { get :show, params: { id: @kid, redacted: 'true' }, format: :md }
      end
    end

    context 'show' do
      it 'renders without an AI review yet' do
        create(:journal, kid: @kid, mentor: @mentor)
        get :show, params: { id: @kid }
        expect(response).to be_successful
      end

      it 'renders without showing the AI review, which is for admins only' do
        Site.load.update!(ai_features_enabled: true)
        create(:journal, kid: @kid, mentor: @mentor)
        @kid.update!(ai_review: "## Signale\nInstabilität: viele Ausfälle", ai_review_generated_at: Time.zone.now)
        get :show, params: { id: @kid }
        expect(response).to be_successful
        expect(response.body).not_to include('Instabilität', 'KI-Auswertung')
      end
    end
  end

  context 'as a admin' do
    before do
      @admin = create(:admin)
      @kid = create(:kid)
      sign_in @admin
    end

    context 'index' do
      it 'filters kids when criteria given' do
        create(:kid, grade: 5)
        create(:kid, grade: 5)
        get :index, params: { kid: { grade: '5' } }
        expect(assigns(:kids).length).to eq(2)
      end

      it 'creates a criteria instance for search' do
        get :index, params: { kid: { grade: '5' } }
        expect(assigns(:filter).grade).to eq('5')
      end

      it 'excludes inactive kids' do
        create(:kid, inactive: true)
        get :index
        expect(response).to be_successful
        expect(assigns(:kids).length).to eq(1)
      end

      it 'renders xlsx' do
        get :index, format: 'xlsx'
        expect(response).to be_successful
        expect(response.headers['Content-Disposition']).to match(/filename="kids-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}\.xlsx"/)
      end
    end

    context 'markdown' do
      it 'renders a markdown representation including journals and reviews in chronological order' do
        create(:journal, kid: @kid, subject: 'Bruchrechnen', held_at: Date.new(2024, 1, 10))
        create(:review, kid: @kid, content: 'Elterngespräch', held_at: Date.new(2024, 1, 20))

        get :show, params: { id: @kid }, format: :md

        expect(response).to be_successful
        expect(response.media_type).to eq('text/markdown')
        expect(response.body.index('Lernjournal vom 10.01.2024'))
          .to be < response.body.index('Gesprächsdokumentation vom 20.01.2024')
      end

      it 'renders a redacted markdown representation when redacted=true is given' do
        mentor = create(:mentor, name: 'Fischer', prename: 'Lea')
        create(:journal, kid: @kid, mentor: mentor, subject: 'Lea kam vorbei.')

        get :show, params: { id: @kid, redacted: 'true' }, format: :md

        expect(response).to be_successful
        expect(response.media_type).to eq('text/markdown')
        expect(response.body).not_to include('Lea')
        expect(response.body).to match(/\[Mentor\d+\]/)
      end

      it 'renders the journal statistics before the timeline' do
        mentor = create(:mentor)
        create(:journal, kid: @kid, mentor: mentor, held_at: Date.new(2024, 1, 10))
        create(:cancelled_journal, kid: @kid, mentor: mentor, held_at: Date.new(2024, 1, 17))
        create(:journal, kid: @kid, mentor: create(:mentor), held_at: Date.new(2024, 1, 31))

        get :show, params: { id: @kid }, format: :md

        expect(response.body).to include(<<~STATS)
          ## Kennzahlen zu Terminen

          - Einträge gesamt: 3
          - Ausfälle gesamt: 1/3
          - Ausfälle im aktuellen Verlauf (seit #{I18n.l(Kid.recent_since)}): keine Einträge (davor: 1/3)
          - Ø Dauer im aktuellen Verlauf (seit #{I18n.l(Kid.recent_since)}): keine durchgeführten Termine (davor: 60 Min.)
            (Hinweis: Nachholstunden/Doppellektionen können diesen Wert nach oben verzerren)
          - Grösster Abstand zwischen zwei Terminen: 21 Tage
          - Mentor:innen-Wechsel: 1 (31.01.2024)

          ## Früherer Verlauf (bis #{I18n.l(Kid.recent_since - 1.day)})
        STATS
      end

      it 'renders the journal statistics of the last two months compared with the time before' do
        mentor = create(:mentor)
        since = Kid.recent_since
        create(:journal, kid: @kid, mentor: mentor, held_at: since - 1.week)
        create(:journal, kid: @kid, mentor: mentor, held_at: since,
                         start_at: Time.zone.parse('13:00'), end_at: Time.zone.parse('14:30'))
        create(:cancelled_journal, kid: @kid, mentor: mentor, held_at: since + 1.week)

        get :show, params: { id: @kid }, format: :md

        period = "im aktuellen Verlauf (seit #{I18n.l(since)})"
        expect(response.body).to include("- Ausfälle #{period}: 1/2 (davor: 0/1)")
        expect(response.body).to include("- Ø Dauer #{period}: 90 Min. (davor: 60 Min.)")
        expect(response.body).to include('- Mentor:innen-Wechsel: 0')
      end

      it 'splits the timeline into the earlier entries and those of the last two months' do
        since = Kid.recent_since
        create(:journal, kid: @kid, subject: 'Alt', held_at: since - 1.day)
        create(:journal, kid: @kid, subject: 'Neu', held_at: since)

        get :show, params: { id: @kid }, format: :md

        earlier, recent = response.body.split("## Aktueller Verlauf (seit #{I18n.l(since)})\n")
        expect(earlier).to include("## Früherer Verlauf (bis #{I18n.l(since - 1.day)})", 'Fach / Thema: Alt')
        expect(earlier).not_to include('Neu')
        expect(recent).to include('Fach / Thema: Neu')
        expect(recent).not_to include('Alt')
      end

      it 'says so when there are no entries in a part of the timeline' do
        create(:journal, kid: @kid, held_at: Date.current - 1.year)

        get :show, params: { id: @kid }, format: :md

        expect(response.body)
          .to end_with("seit #{I18n.l(Kid.recent_since)})\n\nKeine Einträge in diesem Zeitraum.\n\n")
      end

      it 'includes the planned exit with its reason' do
        @kid.update!(exit: '2026 Herbst', exit_reason: 'Übertritt')

        get :show, params: { id: @kid }, format: :md

        expect(response.body).to include("- Geplanter Austritt: 2026 Herbst (Übertritt)\n")
      end

      it 'renders a note instead of the statistics without journals' do
        get :show, params: { id: @kid }, format: :md

        expect(response.body)
          .to include("## Kennzahlen zu Terminen\n\nKeine Lernjournal-Einträge vorhanden.\n\n## Früherer Verlauf (bis ")
      end
    end

    context 'show with the AI review' do
      before do
        Site.load.update!(ai_features_enabled: true)
        create(:journal, kid: @kid)
      end

      it 'shows the AI review as returned and when it was generated' do
        @kid.update!(ai_review: "## Zusammenfassung\nGute Fortschritte.\n\n## Signale\nInstabilität: viele Ausfälle.",
                     ai_review_generated_at: Time.zone.parse('2026-10-31 22:00'))

        get :show, params: { id: @kid }

        expect(response.body)
          .to include('<h2>Zusammenfassung</h2>', 'Gute Fortschritte.', 'Instabilität: viele Ausfälle.')
        expect(response.body).to include('Generiert am 31. Okt', 'hat ein KI-Modell aus den Einträgen erstellt')
        expect(response.body).to include('Nächste Aktualisierung')
        expect(response.body).not_to include('Zusammenfassung erstellen')
      end

      it 'says that no review exists yet' do
        get :show, params: { id: @kid }

        expect(response.body).to include('Es wurde noch keine KI-Auswertung erstellt.')
        expect(response.body).not_to include('hat ein KI-Modell aus den Einträgen erstellt')
      end
    end

    context 'show_kid_mentors_schedules' do
      before do
        @mentor = create(:mentor)
        @school = @mentor.school
        create(:schedule, person: @mentor)
      end

      it 'returns JSON with top-level keys mentors, kid, schools' do
        get :show_kid_mentors_schedules, params: { id: @kid }, format: :json
        expect(response).to be_successful
        body = response.parsed_body
        expect(body.keys).to contain_exactly('mentors', 'kid', 'schools')
      end

      it 'kid data contains expected fields' do
        get :show_kid_mentors_schedules, params: { id: @kid }, format: :json
        kid_data = response.parsed_body['kid']
        expect(kid_data.keys).to include('id', 'prename', 'name', 'mentor_id',
                                         'secondary_mentor_id', 'meeting_start_at',
                                         'meeting_day', 'schedules')
      end

      it 'mentor data contains expected fields' do
        get :show_kid_mentors_schedules, params: { id: @kid }, format: :json
        mentor_data = response.parsed_body['mentors'][@mentor.id.to_s]
        expect(mentor_data.keys).to include('id', 'prename', 'name', 'sex', 'ects',
                                            'kids', 'secondary_kids', 'schools', 'schedules')
      end

      it 'schools is an array with id and display_name' do
        get :show_kid_mentors_schedules, params: { id: @kid }, format: :json
        schools_data = response.parsed_body['schools']
        expect(schools_data).to be_an(Array)
        expect(schools_data.first.keys).to include('id', 'display_name')
      end
    end

    context 'edit_schedules' do
      it 'displays the kids schedule' do
        get :edit_schedules, params: { id: @kid }
        expect(response).to be_successful
      end
    end

    context 'update_schedules' do
      it 'creates a new schedule' do
        post :update_schedules, params: { id: @kid, kid: { schedules_attributes: [attributes_for(:schedule)] } }
        expect(response).to be_redirect
        expect(@kid.schedules.count).to eq(1)
      end
    end

    context 'destroy' do
      it 'can destroy inactive' do
        @kid.update(inactive: true)
        delete :destroy, params: { id: @kid.id }
        expect(Kid).not_to exist(@kid.id)
      end

      it 'cannot destroy active' do
        expect_access_denied do
          delete :destroy, params: { id: @kid.id }
        end
        expect(Kid).to exist(@kid.id)
      end
    end
  end

  context 'as a teacher' do
    before do
      @school = create(:school)
      @teacher = create(:teacher, school: @school)
      sign_in @teacher
    end

    context 'update' do
      it 'does not allow moving an assigned kid to a foreign school' do
        kid = create(:kid, teacher: @teacher, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { school_id: create(:school).id } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow reassigning the mentor' do
        kid = create(:kid, teacher: @teacher, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { mentor_id: create(:mentor).id } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow assigning a coach' do
        kid = create(:kid, teacher: @teacher, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { admin_id: create(:admin).id } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow setting the exit status' do
        kid = create(:kid, teacher: @teacher, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { exit_kind: 'other' } }
        end.to raise_error(SecurityError)
      end

      it 'does not allow setting the inactive flag' do
        kid = create(:kid, teacher: @teacher, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { inactive: true } }
        end.to raise_error(SecurityError)
      end
    end

    context 'create' do
      it 'assigns itself as teacher' do
        post :create, params: { kid: attributes_for(:kid, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.teacher).to eq(@teacher)
        expect(kid.school).not_to be_nil
        expect(kid.school).to eq(@school)
        expect(response).to be_redirect
      end

      it 'assigns itself as teacher even when secondary teacher set' do
        @secondary = create(:teacher)
        post :create, params: { kid: attributes_for(:kid, secondary_teacher_id: @secondary.id, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.teacher).to eq(@teacher)
        expect(kid.secondary_teacher).to eq(@secondary)
        expect(kid.school).not_to be_nil
        expect(response).to be_redirect
      end

      it 'can assign itself as secondary teacher' do
        post :create, params: { kid: attributes_for(:kid, secondary_teacher_id: @teacher.id, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.teacher).to be_nil
        expect(kid.secondary_teacher).to eq(@teacher)
        expect(kid.school).to eq(@school)
        expect(response).to be_redirect
      end

      it 'cannot assign a foreign school' do
        expect do
          post :create, params: { kid: attributes_for(:kid, school_id: 'non-existant') }
        end.to raise_error SecurityError
      end

      it 'tracks creation as relationlog' do
        post :create, params: { kid: attributes_for(:kid) }
        expect(RelationLog.where(role: 'creator').count).to eq(1)
        rl = RelationLog.where(role: 'creator').first
        expect(rl.user).to eq(@teacher)
        expect(rl.role).to eq('creator')
        expect(rl.kid).to eq(assigns(:kid))
      end

      it 'does not track creation on form error' do
        post :create, params: { kid: {} }
        expect(RelationLog.where(role: 'creator').count).to eq(0)
      end
    end
  end

  context 'as a principal' do
    before do
      @school = create(:school)
      @principal = create(:principal, schools: [@school])
      sign_in @principal
    end

    context 'create' do
      it 'is able to create' do
        post :create, params: { kid: attributes_for(:kid, school_id: @school.id) }
        kid = Kid.find(assigns(:kid).id)
        expect(kid.school).to eq(@school)
        expect(response).to be_redirect
      end
    end

    it 'cannot assign a foreign school' do
      expect do
        post :create, params: { kid: attributes_for(:kid, school_id: 'non-existant') }
      end.to raise_error SecurityError
    end

    context 'index' do
      it 'lists only kids of own schools' do
        own_kid = create(:kid, school: @school)
        create(:kid, school: create(:school))
        get :index
        expect(assigns(:kids)).to eq([own_kid])
      end
    end

    context 'update' do
      it 'updates kids of own schools' do
        kid = create(:kid, school: @school)
        put :update, params: { id: kid.id, kid: { name: 'Changed' } }
        expect(kid.reload.name).to eq('Changed')
      end

      it 'denies updating kids of foreign schools' do
        kid = create(:kid, school: create(:school))
        expect_access_denied do
          put :update, params: { id: kid.id, kid: { name: 'Changed' } }
        end
      end

      it 'does not allow moving a kid to a foreign school' do
        kid = create(:kid, school: @school)
        expect do
          put :update, params: { id: kid.id, kid: { school_id: create(:school).id } }
        end.to raise_error(SecurityError)
      end
    end
  end
end
