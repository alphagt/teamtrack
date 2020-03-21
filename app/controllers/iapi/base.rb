module IAPI
  class Base < Grape::API
    mount IAPI::V1::Base
  end
end