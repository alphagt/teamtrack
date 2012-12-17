module ProjectsHelper

	def current_allocation(proj)
		@total = 0
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
		proj.assignments.where(:set_period_id => @cperiod).each do |asn|
			@total = @total + asn.effort
		end
		@total
	end
	def ytd_allocation(proj)
		@total = 0
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
		SetPeriod.where(:fiscal_year => @fyear).each do |sp|
			Assignment.where(:project_id => proj.id, :set_period_id => sp.id).each do |asn|
				@total = @total + asn.effort
			end
		end
		@total
	end
end
