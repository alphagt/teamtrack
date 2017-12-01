module UsersHelper

	def current_project(cuser, tperiod = current_period)
		@cperiod = tperiod
# 		puts "current_project funct - C Period is:"
# 		puts @cperiod
		if cuser.projects.length > 0 then
			@return = cuser.assignments.where(:set_period_id => @cperiod)
		end
		@rStr = ""
# 		puts 'Count of current ASSIGNMENTS:'
# 		puts @return.length
		@return.each do |proj|
			 @rStr = @rStr + proj.project.name + '(' + proj.effort.to_s + ')' + ', '
		end
		@rStr.chomp(", ")
	end
	
	def current_system(cuser, tperiod = current_period)
		@rStr = ""
		if cuser.tech_systems.length > 0 then
			@return = cuser.assignments.where(:set_period_id => tperiod)
			@return.each do |a|
				if !a.tech_system.blank?
					@rStr += a.tech_system.name + ', '
				end
			end
		end
		@rStr.chomp(", ")
	end
	
	def current_assignment(cuser, speriod = current_period)
		if cuser.assignments.where("set_period_id = ?", speriod).length > 0
			cuser.assignments.where(:set_period_id => speriod)
		else
			Array.new()
		end
	end
	
	def latest(cuser, floor = 0)
		if cuser.assignments.where("set_period_id >= ?", floor).length > 0
			@latest = cuser.assignments.where("set_period_id >= ?", floor).order("set_period_id DESC").first.set_period_id	
			cuser.assignments.where(:set_period_id => @latest)
		else
			Array.new()
		end
	end
	
	def latestInfoStr(cuser)
		@str = ""
		tweek = ""
		if cuser.assignments.length > 0
			@latest = cuser.assignments.order("set_period_id DESC").first.set_period_id	
			cuser.assignments.where(:set_period_id => @latest).each do |a|
				@rStr = @rStr + a.project.name + '(' + a.effort.to_s + ')' + ', '
			end
			w = week_from_period(@latest)
			if w < 52 then
				tweek = w + 1
			else
				tweek = (w + 1) - 52
			end
		end
		@rStr.chomp(", ") + " to week: " + tweek.to_s
	end
	
end
