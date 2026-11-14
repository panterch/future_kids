# frozen_string_literal: true

require 'spec_helper'

describe SchoolsController do
  before do
    sign_in @admin = create(:admin)
  end

  context 'new' do
    it 'renders' do
      get :new
      expect(response).to be_successful
    end

    context 'with rendered views' do
      render_views

      it 'suggests the listed and the used values' do
        Site.load.update!(school_subdistricts: "Uto\nLetzi\n")
        create(:school, subdistrict: 'Waidberg', district: 'Schlieren')
        get :new
        options = ->(id) { response.parsed_body.css("datalist##{id} option").pluck(:value) }
        expect(options.call('districts')).to eq(%w[Schlieren])
        expect(options.call('subdistricts')).to eq(%w[Letzi Uto Waidberg])
      end
    end
  end

  context 'create' do
    it 'redirects on success' do
      post :create, params: { school: { name: 'test school' } }
      expect(School.count).to eq(1)
      expect(response).to be_redirect
    end

    it 'renders again on failure' do
      post :create, params: { school: { name: '' } }
      expect(School.count).to eq(0)
      expect(response).to be_successful
    end
  end

  context 'index' do
    before do
      @school = create(:school)
    end

    it 'renders' do
      get :index
      expect(assigns(:schools)).to eq([@school])
      expect(response).to be_successful
    end

    it 'excludes inactive schools by default' do
      create(:school, inactive: true)
      get :index
      expect(assigns(:schools)).to eq([@school])
    end

    it 'shows only inactive schools when filtered' do
      inactive = create(:school, inactive: true)
      get :index, params: { school: { inactive: '1' } }
      expect(assigns(:schools)).to eq([inactive])
    end
  end

  context 'index filtered by subdistrict' do
    it 'shows only the schools of the subdistrict' do
      uto = create(:school, subdistrict: 'Uto')
      create(:school, subdistrict: 'Letzi')
      create(:school)
      get :index, params: { school: { subdistrict: 'Uto' } }
      expect(assigns(:schools)).to eq([uto])
    end

    it 'offers only the filter when a subdistrict is in use' do
      create(:school)
      get :index
      expect(response.body).not_to include('Schulkreis')
      create(:school, subdistrict: 'Uto')
      get :index
      expect(response.body).to include('Schulkreis')
    end
  end

  context 'inactivate via update' do
    before do
      @school = create(:school)
    end

    it 'inactivates a school with no active dependents' do
      put :update, params: { id: @school.id, school: { inactive: '1' } }
      expect(@school.reload.inactive).to be(true)
    end

    it 'blocks inactivation when active kids are present' do
      create(:kid, school: @school)
      put :update, params: { id: @school.id, school: { inactive: '1' } }
      expect(@school.reload.inactive).to be(false)
    end

    it 'blocks inactivation when active teachers are present' do
      create(:teacher, school: @school)
      put :update, params: { id: @school.id, school: { inactive: '1' } }
      expect(@school.reload.inactive).to be(false)
    end
  end

  context 'edit' do
    before do
      @school = create(:school)
    end

    it 'renders' do
      get :edit, params: { id: @school.id }
      expect(assigns(:school)).to eq(@school)
      expect(response).to be_successful
    end
  end

  context 'update' do
    before do
      @school = create(:school)
    end

    it 'redirects on success' do
      put :create, params: { id: @school.id, school: { name: 'updated' } }
      expect(assigns(:school).name).to eq('updated')
      expect(response).to be_redirect
    end

    it 'saves the subdistrict' do
      put :update, params: { id: @school.id, school: { subdistrict: 'Uto' } }
      expect(@school.reload.subdistrict).to eq('Uto')
    end
  end
end
