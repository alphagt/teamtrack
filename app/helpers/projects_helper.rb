module ProjectsHelper

	def current_allocation(proj, sum = 0)
	#ToReview
		@fixed = 0
		@nitro = 0
		@output = "Fixed: "
		@cperiod = current_period() #SetPeriod.where(:fiscal_year => @fyear, :week_number => current_fiscal_week())
		#get fixed assignments total
		if proj.assignments.exists? then
			proj.assignments.where(:set_period_id => @cperiod, :is_fixed => true).each do |asn|
				@fixed = @fixed + asn.effort.round(1)
			end
			@output += @fixed.to_s
# 			puts 'FIXED STRING - '
# 			puts @output
			#get nitro assignments total
			proj.assignments.where(:set_period_id => @cperiod, :is_fixed => false).each do |asn|
				@nitro = @nitro + asn.effort.round(1)
			end
		else
			@output += "0"
		end	
		if sum == 1 then
			@output = (@fixed + @nitro).round(1).to_s
		else
			@output += " | Nitro: " + @nitro.to_s
		end
	end
	def current_fiscal_week
		@pFy = current_period.to_i
		((current_period() - @pFy) * 100).round
#		@cweek_number = 0
#		@fyear = Date.today.year 
#			@cfy_offset = SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
#			@cweek_number = Date.today.cweek + @cfy_offset - 52
#		else
#			@cfy_offset = SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
#			@cweek_number = Date.today.cweek + @cfy_offset
#		end
#		puts 'CURRENT CWEEK Number: '
#		puts  @cweek_number
#		@cweek_number
	end
	def ytd_allocation(proj, sum = 0, fiscaly = current_fy())
	#ToFIX
		puts "ytd_allocation Call"
		puts fiscaly
		@fixtotal = 0
		@nitrototal = 0
		@output = "Fixed: "
		@cperiod = current_period().to_f() #SetPeriod.where(:fiscal_year => @fyear, :week_number => current_fiscal_week())
		@pFy = fiscaly.to_i
		#puts "pFY - "
		#puts @pFy
		if @pFy == current_fy().to_i then
			@fWeek = ((@cperiod - @pFy) * 100).round
		else
			#puts "In Else Clause"
			@fWeek = 52
		end
		puts "fweek = " + @fWeek.to_s
		#ReDesign The following ....
		#SetPeriod.where(:fiscal_year => @fyear, :week_number => (1)..(current_fiscal_week())).each do |sp|
		#Deprecated IMPL
	# 		for iWeek in 1..@fWeek
# 				@cP = @pFy.to_f + (iWeek.to_f / 100)
# 				Assignment.where(:project_id => proj.id, :set_period_id => @cP.round(2)).each do |asn|
# 					if asn.is_fixed then
# 						@fixtotal = (@fixtotal + asn.effort).round(1)
# 					else
# 						@nitrototal = (@nitrototal + asn.effort).round(1)
# 					end
# 				end
# 			end
		#**********
		@fixtotal = Assignment.where("project_id = ? and is_fixed = true and set_period_id between ? and ?",
			proj.id, @pFy.to_f, @pFy.to_f + ((@fWeek+1).to_f/100)).sum(:effort).round(1)
		@nitrototal = Assignment.where("project_id = ? and is_fixed = false and set_period_id between ? and ?",
			proj.id, @pFy.to_f, @pFy.to_f + ((@fWeek+1).to_f/100)).sum(:effort).round(1)
		
		if sum == 1 then
			@output = (@fixtotal + @nitrototal).round(1).to_s
		else
			@output += @fixtotal.to_s + " | Nitro: " + @nitrototal.to_s
		end
	end

end
