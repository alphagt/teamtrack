module ApplicationHelper
	def period_to_date(speriod)
		if speriod.week_number > speriod.cweek_offset then
			Date.commercial(speriod.fiscal_year,speriod.week_number - speriod.cweek_offset,1)
		else
			Date.commercial(speriod.fiscal_year - 1,speriod.week_number - speriod.cweek_offset - 1,1)
		end
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
		@return.sort! {|a,b| a.name <=> b.name}
	end
end
