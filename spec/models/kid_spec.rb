require 'spec_helper'

describe Kid do

  context 'embedded journals' do
    let(:kid) { Factory(:kid) }
    it 'can associate a journal' do
      kid.journals.create
      Kid.find(kid._id).journals.size.should eq(1)
    end
    it 'can populate journal via nested attributes' do
      kid.update_attributes(:journals_attributes =>
                            [{ :subject => 'subject 1' }] )
      kid.journals.size.should eq(1)
    end
    it 'prepares a new journal entry' do
      kid.prepare_new_journal_entry
      kid.journals.size.should eq(1)
    end
  end

end
