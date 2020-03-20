module IAPI
	module V1
		module Helpers
			extend self
			include HTTParty
			
			def current_assignment(sparams, asJson = false, speriod = current_period)
				#get teamview user
				cuser = user_from_slack(sparams)
				out = Hash.new
	  			out["response_type"] = "ephemeral"
	  			out["channel"]=sparams["channel_id"].to_s
	  			if cuser.subordinates.count > 0 then
	  				sblocks = []
	  				sblocks << {type: "section", 
	  					text: {type: "plain_text", emoji: true, text: "Here are your team's current assignments"},
	  					}
	  				sblocks << {type: "divider"}
	  				sblocks << {type: "section",
	  							text: {type: "mrkdwn", text: "x of n employees have assignments this week"}}
	  				sblocks << {type: "divider"}
	  				sblocks << {type: "section",
	  							text: {type: "mrkdwn", text: "*Assignments:*"}}
	  				sblocks << getSlackAssignmentBlock(cuser)
	  				cuser.subordinates.each do |s|
	  					sblocks << getSlackAssignmentBlock(s)
	  				end			
	  				out["text"] = latestInfoStr(cuser)
	  				out["blocks"]=sblocks
	  				puts out.to_json
	  			else
	  				out["text"] = latestInfoStr(cuser)
	  			end
	  			if asJson
	  				out.to_json
	  			else
	  				if sendSlackResponse(sparams["response_url"], out.to_json) then
	  					"..."
	  				else
	  					"Whoops! Something went wrong, try again please."
	  				end
	  			end
			end
	
			def current_period()
				@out = offset_period(Date.today)
				puts 'cPeriod ='
				puts @out
				@out
			end
			
			def getSlackAssignmentBlock(e)
				astring = latestInfoStr(e)
				block = Hash.new
				block["type"] = "section"
				btext = Hash.new
				btext["type"]="mrkdwn"
				btext["text"]= "*" + astring + "*"
				block["text"] = btext
				bextend = Hash.new
				bextend["type"]="button"
				bextend["text"]={type: "plain_text", emoji: true, text: "Extend"}
				bextend["value"]="extend_" + astring.split("(")[0]
				block["accessory"]=bextend
				block
			end
	
			def offset_period(d, hardOffset = 53)
				@cweek_number = 0.0
				@fyear = d.year 
				if hardOffset == 53 then
					@cfy_offset = display_name_for('sys_names', 'fy offset').to_i
				else
					@cfy_offset = hardOffset
				end
				puts 'OFFSET = ?',@cfy_offset
				if @cfy_offset == 0 then
					@offset_y_adjust = 0
				else
					@offset_y_adjust = @cfy_offset/@cfy_offset.abs
				end

				#handle special case at start or end of calendar year
				if d.cweek <= @cfy_offset || d.cweek > (52 + @cfy_offset) then
					@fyear = @fyear - @offset_y_adjust
					@cweek_number = (52 - (@cfy_offset - d.cweek).abs).abs
				else
					@cweek_number = d.cweek - @cfy_offset
				end
				@out = @fyear + @cweek_number.fdiv(100).round(3)
			end

			def display_name_for(key, val)
				out = 'Undefined'

				if !Setting.find_by_key(key).nil?
					s = Setting.for_key(key).where('value = ?', val)
					if s.length > 0
						out = s.first.displayname || "blank"
					else
						#handle legacy situation where stored 'val' is actually the displayname
						if Setting.for_key(key).where('displayname = ?', val).length > 0
							#val is the displayname
							out = val
						end
					end
				end
				out
			end
			
			def user_from_slack(sparams)
				sUid = sparams["user_id"].to_s
				tvUser = User.find_by_slackid(sUid)
				if !tvUser
					#fall back search and set slackid
					tvUser = User.find_by_name(sparams["user_name"].to_s)
					if !tvUser
						#pull the slack profile to get email address and update user with slack id
						#TEMP RETURN
						tvUser = link_slack_user(sparams)
					else
						#add slack id to user
						tvUser.slackid = sparams["user_id"].to_s
						tvUser.save
					end
				end
				tvUser
			end
			
			def link_slack_user(sparams)
				#given a slack request, call get profile, use email address to link to teamview user
				puts "in Link Slack User"
				puts ENV["Slack_API_Key"].truncate(6)
				client = Slack::Web::Client.new(:token => ENV["Slack_API_Key"])
# 				puts client.auth_test
				uio = client.users_info(user: sparams["user_id"].to_s)
				email = uio["user"]["profile"]["email"].to_s	
				puts email			
#				puts uio
				#TEMP RETURN
				u = User.find_by_email(email)
				if u.nil? then
					#try with name
					u = User.find_by_name(uio["user"]["real_name"].to_s)
				end
				if !u.nil? then
					u.slackid = uio["user"]["id"].to_s
					u.save
				else
					#failed to find this user
					u = nil
				end	
				u
			end
			
			def week_from_period(p)
				((p - p.to_i)*100).round
			end
			
			def extendlatest(cuser, sparams, floor = 0)
				if cuser.assignments.where("set_period_id >= ?", floor).length > 0
					@latest = cuser.assignments.where("set_period_id >= ?", floor).order("set_period_id DESC").first.set_period_id	
					cuser.assignments.where(:set_period_id => @latest).each do |a|
						Assignment.extend_by_week(a)
					end
					r = Hash.new
					r["response_type"]="ephemeral"
					r["channel"]=sparams.with_indifferent_access["container"]["channel_id"]
					r["text"]="Assignments for " + cuser.name + " extended one week!"
					sendSlackResponse(sparams.with_indifferent_access["response_url"],r)
					out = true
				else
					Array.new()
					out = false
				end
			end
			
			def latestInfoStr(cuser)
				@rStr = ""
				tweek = ""
				if cuser.assignments.length > 0
					@latest = cuser.assignments.order("set_period_id DESC").first.set_period_id	
					puts "PROCESSING assignments for - " + @latest.to_s
					cuser.assignments.where(:set_period_id => @latest).each do |a|
						puts a.to_json
						@rStr = @rStr + a.project.name + '(' + a.effort.to_s + ')' + ', '
					end
					w = week_from_period(@latest)
					if w < 52 then
						tweek = w + 1
					else
						tweek = (w + 1) - 52
					end
				end
				cuser.name + "(week " + w.to_s + "): " + @rStr.chomp(", ") 
			end
			
			def sendSlackResponse(respUrl, resp)
				#send a message via slack using a response_url
				puts "Sending Slack Response ..."
				puts respUrl
				puts resp
				out = true
				headers = { 'Content-Type' => 'application/json' }
				begin
					r = HTTParty.post(respUrl, body: resp, headers: headers)
					puts "response #{r.body}"
					return(r.code == 200)
				rescue
     				puts "response #{r}"
     				return false
 				end
				out
			end

		end
	end
end