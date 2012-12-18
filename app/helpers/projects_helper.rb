module ProjectsHelper

	def current_allocation(proj)
		@total = 0
		@output = "Fixed: "
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
		#get fixed assignments total
		proj.assignments.where(:set_period_id => @cperiod, :is_fixed => true).each do |asn|
			@total = @total + asn.effort
		end
		@output += @total.to_s
		puts 'FIXED STRING - '
		puts @output
		#get nitro assignments total
		@total = 0
		proj.assignments.where(:set_period_id => @cperiod, :is_fixed => false).each do |asn|
			@total = @total + asn.effort
		end
		@output += " | Nitro: " + @total.to_s
	end
	def ytd_allocation(proj)
		@fixtotal = 0
		@nitrototal = 0
		@output = "Fixed: "
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
				if asn.is_fixed then
					@fixtotal += asn.effort
				else
					@nitrototal += asn.effort
				end
			end
		end
		@output += @fixtotal.to_s
		@output += " | Nitro: " + @nitrototal.to_s
	end
end
