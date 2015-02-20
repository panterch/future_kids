class ExceptionTestController < ApplicationController

  # this creates an excpetion - use this to test the exception notification
  # * login
  # * call /exception_test
  def error
    raise 'hit a tree'
  end
 
end
