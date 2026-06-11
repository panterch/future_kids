# frozen_string_literal: true

class ExceptionTestController < ApplicationController
  include AdminOnly

  # there is no resource to authorize here - access is restricted via AdminOnly
  skip_authorization_check

  # this creates an exception - use this to test the exception notification
  # * login as admin
  # * call /exception_test
  def error
    raise 'hit a tree'
  end
end
