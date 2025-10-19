module Iapi
  class Base < Grape::API
    mount Iapi::V1::Base
  end
end