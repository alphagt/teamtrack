module IAPI
  module V1
    class Assignments < IAPI::V1::Base
      include IAPI::V1::Defaults


	  params do
	  	requires :user_id, type: String
	  	requires :user_name, type: String
	  	requires :command, type: String
	  end
	  post do
	  	puts params
	  	case params["command"]
	  		when '/getmyassignments'
	  			Helpers.current_assignment(params)

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