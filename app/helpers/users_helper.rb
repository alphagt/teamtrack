module UsersHelper

	def current_project(cuser)
		@cperiod = current_period
		puts "current_project funct - C Period is:"
		puts @cperiod
		if cuser.projects.length > 0 then
			@return = cuser.assignments.where(:set_period_id => @cperiod)
		end
		@rStr = ""
		puts 'Count of current ASSIGNMENTS:'
		puts @return.length
		@return.each do |proj|
			 @rStr = @rStr + proj.project.name + '(' + proj.effort.to_s + ')' + ', '
		end
		@rStr.chomp(", ")
	end
	
	def current_system(cuser)
		@rStr = ""
		if cuser.tech_systems.length > 0 then
			@return = cuser.assignments.where(:set_period_id => current_period)
			@return.each do |a|
				if !a.tech_system.blank?
					@rStr += a.tech_system.name + ', '
				end
			end
		end
		@rStr.chomp(", ")
	end
end
