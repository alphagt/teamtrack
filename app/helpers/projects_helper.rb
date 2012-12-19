module ProjectsHelper

	def current_allocation(proj)
		@total = 0
		@output = "Fixed: "
		@cperiod = SetPeriod.where(:fiscal_year => @fyear, :week_number => current_fiscal_week())
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
	def current_fiscal_week
		@cweek_number = 0
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
		@cweek_number
	end
	def ytd_allocation(proj)
		@fixtotal = 0
		@nitrototal = 0
		@output = "Fixed: "
		#@cperiod = SetPeriod.where(:fiscal_year => @fyear, :week_number => current_fiscal_week())
		SetPeriod.where(:fiscal_year => @fyear, :week_number => (1)..(current_fiscal_week())).each do |sp|
			Assignment.where(:project_id => proj.id, :set_period_id => sp.id).each do |asn|
				if asn.is_fixed then
					@fixtotal = @fixtotal + asn.effort
				else
					@nitrototal = @nitrototal + asn.effort
				end
			end
		end
		@output = @output + @fixtotal.to_s
		@output += " | Nitro: " + @nitrototal.to_s
	end
end
