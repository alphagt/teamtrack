module UsersHelper

	def current_project(cuser)
		@cweek_number = 0
		@cperiod = 0
		@fyear = Date.today.year 
		if Date.today.mon == 12 then
			@fyear = @fyear + 1
			@cfy_offset = SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
			@cweek_number = Date.today.cweek + @cfy_offset - 52
		else
			@cfy_offset = SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
			@cweek_number = Date.today.cweek + @cfy_offset
		end
		puts 'CURRENT CWEEK Number: '
		puts  @cweek_number
		@cperiod = SetPeriod.where(:fiscal_year => @fyear, :week_number => @cweek_number)
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
	def all_subs(mid)
		@manager = User.find(mid)
		@return = Array.new()
		puts "MANAGER IS-" + @manager.name
		if @manager.subordinates.any?
			# puts "-FOUND SUBORDINATES"
			@return = @manager.subordinates
			# puts "Return Length - " 
# 			puts @return.length
			@manager.subordinates.each do |s|
				if s.subordinates.any?
					# puts "---FOUND SUBORDINATES"	
					@return |= all_subs(s.id)
				end
			end
		end
		@return
	end
end
