require 'spec_helper'

describe ApplicationHelper do

  describe 'boolean_collection' do
    it 'includes true' do
      expect(helper.boolean_collection).to include('Ja' => true)
    end
  end

end