require 'spec_helper'

describe Journal do

  it "should calculate duration" do
    j = Factory(:journal, :start_at => '14:00', :end_at => '14:30')
    j.duration.should eq(30)
  end



end
