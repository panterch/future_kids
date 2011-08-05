require 'spec/spec_helper'

describe SchedulesController do

  context 'as an admin' do

    before(:each) do
      @admin = Factory(:admin)
      @mentor = Factory(:mentor)
      sign_in @admin
    end

    context 'index' do
      it 'should index' do
        get :index, :mentor_id => @mentor.id
        response.should be_successful
      end
    end

  end

  it 'should not allow access as mentor' do
    @mentor = Factory(:mentor)
    sign_in @mentor
    expect { get :index }.to raise_error(SecurityError)
  end

end
