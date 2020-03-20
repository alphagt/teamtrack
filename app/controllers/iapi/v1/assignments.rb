module IAPI
  module V1
    class Assignments < IAPI::V1::Base
      include IAPI::V1::Defaults
      require 'json'
      require 'uri'
	  require 'net/http'

	  params do
# 	  	requires :user_id, type: String
# 	  	requires :user_name, type: String
# 	  	requires :command, type: String
	  end
	  post do
	  	puts "Handle Post Request"
	  	if params["command"].present? then
			case params["command"]
				when '/getmyassignments'
					ru = URI(params["response_url"])
					puts ru
					if !Helpers.sendSlackResponse(params["response_url"], Helpers.current_assignment(params, true)) then
						"Oops!  Something went wrong.  Please try again"
					else
						''	
					end
			end
		end
		if params["payload"].present? then
	  		payload = JSON.parse(params["payload"], object_class: Hash, allos_nan: true, symbolize_names:true)
			if !payload.is_a?(Hash) then
				payload = JSON.parse(payload, symbolize_names: true)
			end
	  		puts "###############"
			puts payload
			
	  		if payload[:type] == "block_actions"
				puts "Caught a button click"
				uname = payload[:actions][0][:value]
# 				puts uname
				tuser = User.find_by_name(uname.split("_").last)
				Helpers.extendlatest(tuser, payload)
				''
			end 
			#TODO handle errors if the extend fails
		end
	  end
      resource :assignments do
        desc "Return all self and subordinate assignments"
        get "", root: :assignments do
          puts "Got request for all assignments via API"
          puts params
          Helpers.current_assignment(params)
          #Assignment.first.to_json
        end

        desc "Return a graduate"
        params do
          requires :id, type: String, desc: "ID of the 
            team member"
        end
        get ":id", root: "assignment" do
          puts "Got request for users assignments via API"
          Assignment.by_user(permitted_params[:id]).to_json
        end
      end
    end
  end
end