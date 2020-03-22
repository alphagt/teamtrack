module IAPI
	module V1
		module Helpers
			extend self
			
			def current_assignment(sparams, asJson = false, speriod = current_period)
				#get teamview user
				cuser = user_from_slack(sparams)
				out = Hash.new
	  			out["response_type"] = "ephemeral"
	  			out["channel"]=sparams["channel_id"].to_s
	  			scount = cuser.subordinates.count
	  			if scount > 0 then
	  				sblocks = []
	  				sblocks << {type: "section", 
	  					text: {type: "plain_text", emoji: true, 
	  					text: "Here are your team's current assignments (week-" + 
	  						week_from_period(speriod).to_s + ")"},
	  					}
	  				sblocks << {type: "divider"}
	  				acount = current_subordinates_assigned(cuser)
	  				mstr = acount.to_s + " of " + scount.to_s + " employees have assignments this week"
	  				sblocks << {type: "section",
	  							text: {type: "mrkdwn", text: mstr}}
	  				sblocks << {type: "divider"}
	  				sblocks << {type: "section",
	  							text: {type: "mrkdwn", text: "*Assignments:*"}}
	  				sblocks << getSlackAssignmentBlock(cuser, speriod)
	  				cuser.subordinates.each do |s|
	  					sblocks << getSlackAssignmentBlock(s, speriod)
	  				end			
	  				out["text"] = latestInfoStr(cuser, speriod)
	  				out["blocks"]=sblocks
	  			else
	  				out["text"] = latestInfoStr(cuser, speriod)
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
			
			def current_subordinates_assigned(mid, speriod = current_period)
				iout = 0
				User.find(mid).subordinates.each do |s|
					if s.assignments.where("set_period_id =?", speriod).length > 0 
						iout += 1
					end
				end
				iout
			end
			
			def getSlackAssignmentBlock(e, prd = current_period)
				puts "IN Assign Block Call"
				astring = latestInfoStr(e, prd)
				puts "InfoString - #{astring}"
				block = Hash.new
				block["type"] = "section"
				btext = Hash.new
				btext["type"]="mrkdwn"
				btext["text"]= "*" + astring + "*"
				block["text"] = btext
				
# 				puts astring.split(":")[1].rstrip.length
				if astring.split(":")[1].rstrip.length > 0 then
					bextend = Hash.new
					bextend["type"]="button"
					bextend["text"]={type: "plain_text", emoji: true, text: "Extend"}
					bextend["value"]="extend_" + astring.split("(")[0]
					block["accessory"]=bextend
				end
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
			
			def period_from_week(w)
				@fWeek = w.to_i
				puts @fWeek.to_s
				current_period.to_i + @fWeek.fdiv(100).round(3)
			end
			
			def validateSetParams(prs)
				errs = []
				#check user
				if !User.find_by_name(prs[0].strip.to_s) then
					errs << "User " + prs[0].strip.to_s + " NOT Found in TeamView!"
					return errs
				end
				if !Project.find_by_name(prs[1].strip.to_s) then
					errs << "Project " + prs[1].strip.to_s + " NOT Found in TeamView!"
					return errs
				end
				w = Integer(prs[2]) rescue nil
				if w.nil? || w > 52 then 
					errs << "Invalid Week Number!"
					return errs
				end
				if prs[3].to_d > 1 then
					errs << "Effort value must be between 0 and 1"
					return errs
				end
				return errs
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
					sendSlackResponse(sparams.with_indifferent_access["response_url"],r.to_json)
					out = true
				else
					Array.new()
					out = false
				end
			end
			
			def latestInfoStr(cuser, tperiod = 0)
				@rStr = ""
				tweek = """"
				if cuser.assignments.length > 0
					if tperiod == 0 then
						@latest = cuser.assignments.order("set_period_id DESC").first.set_period_id	
					else
						@latest = tperiod
					end
					puts "PROCESSING assignments for - " + @latest.to_s
					cuser.assignments.where(:set_period_id => @latest).each do |a|
						puts a.to_json
						@rStr = @rStr + a.project.name + '(' + a.effort.to_s + ')' + ', '
					end
				end
				tweek = week_from_period(@latest)
				cuser.name + "(week " + tweek.to_s + "): " + @rStr.chomp(", ") 
			end
			
			def sendSlackResponse(respUrl, resp)
				#send a message via slack using a response_url
				out = SlackJob.perform_async(respUrl, resp)
			end
			
			class SlackJob

			include SuckerPunch::Job
			include HTTParty

			  def perform(respUrl, resp)
				headers = { 'Content-Type' => 'application/json' }
				puts "Sending Slack Response ..."
				puts respUrl
				puts resp
				begin
					r = HTTParty.post(respUrl, body: resp, headers: headers)
					puts "response #{r.body}"
					return(r.code == 200)
				rescue
					puts "response #{r}"
					return false
				end
			  end
			end

		end
	end
end