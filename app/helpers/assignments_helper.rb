module AssignmentsHelper
	def latest(cuser)
		# @cweek_number = 0
# 		@cperiod = 0
# 		@fyear = Date.today.year 
# 		if Date.today.mon == 12 then
# 			@fyear = @fyear + 1
# 			@cfy_offset = SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
# 			@cweek_number = Date.today.cweek + @cfy_offset - 52
# 		else
# 			@cfy_offset = SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
# 			@cweek_number = Date.today.cweek + @cfy_offset
# 		end
		#puts 'CURRENT CWEEK Number: '
		#puts  @cweek_number
		#@cperiod = SetPeriod.where(:fiscal_year => @fyear, :week_number => @cweek_number)
		# if cuser.projects.length > 0 then
# 			@all = cuser.assignments.order("set_period_id DESC")
# 		end
	
		@latest = cuser.assignments.order("set_period_id DESC").first.set_period_id
		puts 'Last period id - '
		puts @latest	
		cuser.assignments.where(:set_period_id => @latest)
	end
	
end
