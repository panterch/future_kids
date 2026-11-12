# frozen_string_literal: true

require 'spec_helper'

# /up is what an uptime monitor calls: it must answer without a login
describe 'Health check' do
  it 'answers 200 without signing in' do
    get rails_health_check_path

    expect(rails_health_check_path).to eq('/up')
    expect(response).to have_http_status(:ok)
  end
end
