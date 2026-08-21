# frozen_string_literal: true

RSpec.describe 'Rack::Attack throttling', type: :request do
  # The test environment uses a null cache store so Rack::Attack's counters never persist
  # (see config/environments/test.rb) - swap in a real store just for these examples.
  around do |example|
    original_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    example.run
    Rack::Attack.cache.store = original_store
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
