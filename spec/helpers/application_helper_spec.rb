require 'spec_helper'

describe ApplicationHelper do

  describe 'boolean_collection' do
    it 'includes true' do
      expect(helper.boolean_collection).to include('Ja' => true)
    end
  end

  describe 'human date' do
    it 'formats dates' do
      expect(helper.human_date(Date.parse('1980-01-30'))).to eq('30.01.1980')
    end
    it 'guards nil' do
      expect(helper.human_date(nil)).to be_nil
    end
  end

end
