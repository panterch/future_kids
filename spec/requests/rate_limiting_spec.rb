# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate limiting', type: :request do
  # The test environment uses a null cache store so rate limit counters never persist
  # (see config/environments/test.rb). rate_limit captures the store when the controller
  # class is loaded, so route its counters to a real store just for these examples.
  before do
    counters = ActiveSupport::Cache::MemoryStore.new
    allow(ActionController::Base.cache_store).to receive(:increment) do |*args, **options|
      counters.increment(*args, **options)
    end
  end

  it 'throttles repeated sign-in attempts against a single account' do
    10.times do
      post user_session_path, params: { user: { email: 'someone@example.com', password: 'wrong' } }
      expect(response).not_to have_http_status(:too_many_requests)
    end

    post user_session_path, params: { user: { email: 'someone@example.com', password: 'wrong' } }
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'throttles repeated sign-in attempts from a single IP across different accounts' do
    20.times do |i|
      post user_session_path, params: { user: { email: "someone#{i}@example.com", password: 'wrong' } }
      expect(response).not_to have_http_status(:too_many_requests)
    end

    post user_session_path, params: { user: { email: 'yet-another@example.com', password: 'wrong' } }
    expect(response).to have_http_status(:too_many_requests)
  end

  it 'throttles repeated password reset requests from a single IP' do
    10.times do
      post user_password_path, params: { user: { email: 'someone@example.com' } }
      expect(response).not_to have_http_status(:too_many_requests)
    end

    post user_password_path, params: { user: { email: 'someone@example.com' } }
    expect(response).to have_http_status(:too_many_requests)
  end
end
