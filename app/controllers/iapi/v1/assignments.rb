module IAPI
  module V1
    class Assignments < IAPI::V1::Base
      include IAPI::V1::Defaults


	  params do
# 	  	requires :user_id, type: String
# 	  	requires :user_name, type: String
# 	  	requires :command, type: String
	  end
	  post do
	  	puts params
	  	if params["command"].present? then
			case params["command"]
				when '/getmyassignments'
					ru = URI(params["response_url"])
					puts ru
					if Helpers.sendSlackResponse(params["response_url"], Helpers.current_assignment(params, true)) then
						Hash.new
					else
						"Oops!  Something went wrong.  Please try again"	
					end
			end
		end
		if params["type"] == "block_actions" then
			puts "Caught a button click"
			tuser = User.find_by_name(params["actions"]["value"].split("_").last)
			Helpers.extendlatest(tuser, params) 
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