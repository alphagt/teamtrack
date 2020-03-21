desc 'Shift period ids for all assignments'
task :brute_fix_periods => :environment do
  ARGV.each {|a| task a.to_sym do ; end }
  
  puts "Shift in Weeks:  " + ARGV[1].to_s
  puts "Ending Offset:   " + ARGV[2].to_s
  
  @shift = ARGV[1].split(".")
  if @shift[0] == 'n' then
  	@sval = @shift[1].to_i * -1
  else
  	@sval = @shift[1].to_i
  end
  
  @offs = ARGV[2].split(".")
  if @offs[0] == 'n' then
  	@osv = @offs[1].to_i * -1
  else
  	@osv = @offs[1].to_i
  end
  
  puts "Shift Value:   " + @sval.to_s
  puts "End Offset:    " + @osv.to_s
  
  asnPerDate = Assignment.select("set_period_id").distinct.pluck(:set_period_id)
      	puts "Date Correction Update Quant: ?", asnPerDate.count
      	asnPerDate.each do |a|
			puts "-- Original Period: " + a.to_s
      		d = period_to_date(a)
      		puts "-- Original Date: " + d.to_s
			newD = d + (@sval*7)
			puts "---- New Date: " + newD.to_s
      		newP = offset_period(newD,@osv)
			puts "---- New Period:  " + newP.to_s
      		Assignment.where("set_period_id = ?", a).update_all(set_period_id: newP)
      	end
end

def period_to_date(speriod)
		@cweek_number = 0.0
		
		@fyear = speriod.to_i
		@cfy_offset = Setting.where("value = 'fy offset'")[0].displayname.to_i * -1
		#puts "OFFSET = " + @cfy_offset.to_s
		if @cfy_offset == 0 then
			@offset_y_adjust = 0
		else
			@offset_y_adjust = @cfy_offset/@cfy_offset.abs
		end
		@cweek_number = ((speriod.to_f - speriod.to_i) * 100).round

		#handle special case at start or end of calendar year
		if @cweek_number <= @cfy_offset || @cweek_number > (52 + @cfy_offset) then
			@fyear = @fyear - @offset_y_adjust
			@cweek_number = (52 - (@cfy_offset - @cweek_number).abs).abs
		else
			@cweek_number = @cweek_number - @cfy_offset
		end

		Date.commercial(@fyear, @cweek_number, 1)	
end
def offset_period(d, hardOffset = 53)
		@cweek_number = 0.0
		@fyear = d.year 
		@cfy_offset = hardOffset
		#puts "OFFSET = " + @cfy_offset.to_s
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
