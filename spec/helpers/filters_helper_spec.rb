# frozen_string_literal: true

require 'spec_helper'

describe FiltersHelper do
  def stub_request(query)
    allow(helper).to receive(:request)
      .and_return(instance_double(ActionDispatch::Request, path: '/kids', query_parameters: query))
  end

  def query_of(path)
    Rack::Utils.parse_nested_query(URI(path).query)
  end

  describe '#filter_option_path' do
    it 'sets the field under the record param key and keeps the other params' do
      stub_request('kid' => { 'grade' => '3' }, 'order_by' => 'name')
      path = helper.filter_option_path(Kid.new, :meeting_day, 2)

      expect(path).to start_with('/kids?')
      expect(query_of(path)).to eq('kid' => { 'grade' => '3', 'meeting_day' => '2' }, 'order_by' => 'name')
    end

    it 'replaces the current value of the field' do
      stub_request('kid' => { 'grade' => '3' })
      expect(query_of(helper.filter_option_path(Kid.new, :grade, 4))).to eq('kid' => { 'grade' => '4' })
    end

    it 'sends a blank value for "Alle"' do
      stub_request('kid' => { 'grade' => '3' })
      expect(query_of(helper.filter_option_path(Kid.new, :grade, ''))).to eq('kid' => { 'grade' => '' })
    end

    it 'sets the field top level without a record' do
      stub_request('kid' => { 'grade' => '3' })
      expect(query_of(helper.filter_option_path(nil, 'order_by', 'checked_at')))
        .to eq('kid' => { 'grade' => '3' }, 'order_by' => 'checked_at')
    end
  end

  describe '#filters_active?' do
    it 'is true for a filtered attribute' do
      stub_request('kid' => { 'grade' => '3' })
      expect(helper.filters_active?(Kid.new(grade: '3'))).to be(true)
    end

    it 'skips writers without a reader, e.g. nested attributes' do
      stub_request('kid' => { 'schedules_attributes' => [{ 'day' => '1' }] })
      expect(helper.filters_active?(Kid.new)).to be(false)
    end
  end

  describe '#selected_filter_label' do
    let(:inactive_options) { [['Aktiv', false], ['Inaktiv', true]] }

    it 'finds the option of a typecast value' do
      expect(helper.selected_filter_label(inactive_options, false)).to eq('Aktiv')
      expect(helper.selected_filter_label(inactive_options, true)).to eq('Inaktiv')
    end

    it 'compares as strings' do
      expect(helper.selected_filter_label([['3. Klasse', 3]], '3')).to eq('3. Klasse')
    end

    it 'is nil without a matching option' do
      expect(helper.selected_filter_label(inactive_options, nil)).to be_nil
      expect(helper.selected_filter_label([['3. Klasse', 3]], '')).to be_nil
    end
  end
end
