module IAPI
  module V1
    class Slackhandler < IAPI::V1::Base
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
	  	out = ""
	  	if params["command"].present? then
			case params["command"]
				when '/getmyassignments'
# 					ru = URI(params["response_url"])
# 					puts ru
					if params["text"].present? then
						 p = Helpers.period_from_week(params["text"]) || Helpers.current_period
					else
						p = Helpers.current_period
					end
					if !Helpers.sendSlackResponse(params["response_url"], Helpers.current_assignment(params, true, p)) then
						out = "Oops!  Something went wrong.  Please try again"
					else
						puts "get assignments success"
						status 200
						out = '...'	
					end
				when '/setassignment'
					if !params["text"].present? then
						out = "Ooops!  This call requires an employee name, project name, and effort value."
					else
						aparams = params["text"].split(",")
						puts aparams
						if aparams.length < 4 then
							out = "Ooops!  Wrong parameters, please try again"
						else
							v = Helpers.validateSetParams(aparams)
							if v.length > 0 then
								#param errors
								out = v[0]
							else
								mgr = Helpers.user_from_slack(params)
								u = User.find_by_name(aparams[0].strip.to_s)
								if u.manager == mgr then
									tsv = u.default_system_id
									prj = Helpers.getProjectId(aparams[1].strip.to_s)
									period = Helpers.period_from_week(aparams[2])
									eff = aparams[3].to_d
									if Assignment.create!({user_id: u.id, project_id: prj, tech_sys_id: tsv, set_period_id: period, effort: eff}) then
										out = "Assignment Created!"
									else
										out = "Whoops!   that didn't work."
									end
								else
									out = "Hey! That's not cool.  You don't have permission to assign that user!"
								end
							end
						end
					end
				when '/whatsup'
					puts "In WhatsUp handler"
					if !Helpers.sendSlackResponse(params["response_url"], Helpers.getProjectAlloc(params)) then
						out = "Whoops!  Something went wrong, please try again."
					else
						out = "..."
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
				status 200
				out = ''
			end 
			#TODO handle errors if the extend fails
		end
		out
	  end
	end
  end
end