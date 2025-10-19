module Iapi
  module V1
    class Base < Grape::API
    	include Iapi::V1::Helpers


      mount Iapi::V1::Assignments
      mount Iapi::V1::Slackhandler
    end
  end
end