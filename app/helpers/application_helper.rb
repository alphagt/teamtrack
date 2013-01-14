module ApplicationHelper
	def period_to_date(speriod)
		if speriod.week_number > speriod.cweek_offset then
			Date.commercial(speriod.fiscal_year,speriod.week_number - speriod.cweek_offset,1)
		else
			Date.commercial(speriod.fiscal_year - 1,speriod.week_number - speriod.cweek_offset - 1,1)
		end
	end

	def all_subs(mid)
		@m = User.find(mid)
		@return = Array.new()
		puts "MANAGER IS-" + @m.name
		if @m.subordinates.any?
			# puts "-FOUND SUBORDINATES"
			@return = @m.subordinates
			# puts "Return Length - " 
# 			puts @return.length
			@m.subordinates.each do |s|
				if s.subordinates.any?
					# puts "---FOUND SUBORDINATES"	
					@return |= all_subs(s.id)
				end
			end
		end
		@return.sort_by! {|a| [a.manager.name, a.name]}
	end
	
	def latest(cuser)
		if cuser.assignments.length > 0
			@latest = cuser.assignments.order("set_period_id DESC").first.set_period_id	
			cuser.assignments.where(:set_period_id => @latest)
		else
			Array.new()
		end
	end
	
	def extend_team(mUser)
		rcode = 0
		all_subs(mUser.id).each do |u|
			latest(u).each do |a|
				if Assignment.extend_by_week(a) then
					rcode += 1
				end
			end
		end
		rcode
	end
	
	def current_period()
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
		SetPeriod.where(:fiscal_year => @fyear, :week_number => @cweek_number).first
	end
	
	def period_list()
		if current_user.admin? then
			l = SetPeriod.all
		else
			l = SetPeriod.where("id >= " + current_period().id.to_s).all	
		end
	end
	
end
