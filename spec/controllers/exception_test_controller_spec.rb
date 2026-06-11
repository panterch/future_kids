# frozen_string_literal: true

require 'spec_helper'

describe ExceptionTestController do
  it 'raises the test exception for admins' do
    sign_in create(:admin)
    expect { get :error }.to raise_error(RuntimeError, 'hit a tree')
  end

  it 'denies access for non-admins' do
    sign_in create(:mentor)
    expect { get :error }.to raise_error(SecurityError)
  end
end
