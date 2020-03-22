module IAPI
  module V1
    class Base < Grape::API
    	include IAPI::V1::Helpers


      mount IAPI::V1::Assignments
      mount IAPI::V1::Slackhandler
    end
  end
end