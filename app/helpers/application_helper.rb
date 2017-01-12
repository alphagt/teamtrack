module ApplicationHelper
	def period_to_date(speriod)
	#ToFix
		#if speriod.week_number > speriod.cweek_offset then
		#	Date.commercial(speriod.fiscal_year,speriod.week_number - speriod.cweek_offset,1)
		#else
		#	Date.commercial(speriod.fiscal_year - 1,speriod.week_number - speriod.cweek_offset - 1,1)
		#end
		@pPeriod = speriod.to_f
		#puts @pPeriod.to_s
		@pFy = speriod.to_i
		@fWeek = ((@pPeriod - @pFy) * 100).round
		#puts @fWeek
		if @fWeek <= 4
			@pFy -= 1
			@cWeek = 52 - (4 - @fWeek)
		else
			@cWeek = @fWeek - 4
		end
		Date.commercial(@pFy,@cWeek,1)
	end

	def period_from_parts(iFy, iWeek)
 
 		puts 'period_from_parts'
 		puts 'iWeek'
 		puts iWeek
		@fWeek = iWeek.to_f / 100
		puts @fWeek
		@return = iFy.to_f + @fWeek.to_f
	end
	
	def current_week()
		@cp = current_period()
		@fWeek = ((@cp - @cp.to_i) * 100).round
	end
	
	def current_fy()
		current_period().to_i
	end
	
	def week_from_period(p)
# 		puts "Week from period:  " + p.to_s
		((p - p.to_i)*100).round
# 		puts "-- " + out.to_s
# 		out
	end
	
	def current_quarter()
		@cw = current_week()
		@q = 0
		case 
		when @cw < 13
			@q = 1
		when 12 < @cw < 25
			@q = 2
		when 24 < @cw < 37
			@q = 3
		when @cw > 36
			@q = 4
		end
		@q		
	end
	
	def all_subs(mid, showEx = false, subCall = false, by_mgr = true)
		@m = User.find(mid)
		@return = Array.new()
		puts "MANAGER IS-" + @m.name
		puts "showEx is-" + showEx.to_s
		puts "subCall is-" + subCall.to_s
		if @m.subordinates.any?
			# puts "-FOUND SUBORDINATES"
			@exId = User.find_by_name("ExEmployeeMgr").id
			if showEx
				@return = @m.subordinates
			else
				@return = @m.subordinates.where('users.id != ? AND users.manager_id != ?', @exId, @exId).order(:name)
			end
			# puts "Return Length - " 
# 			puts @return.length
			@m.subordinates.each do |s|
				if s.subordinates.any?
					puts "---FOUND Sub-SUBORDINATES"
					puts s.name	
					@return |= all_subs(s.id, false, true)
					#puts @return
				end
			end
			# add exManager reports if indicated
			if showEx && !subCall then
				@return |= all_subs(@exId, true, true, by_mgr)
			end
			if @return.respond_to?(:order)
				puts "--- list is in active record form"
				#puts @return.pluck(:name)
				if by_mgr
					@return.ordered_by_manager
				else
					@return
				end
				
			else
				@return
			end
		else
			@return
		end
		if @return.respond_to?(:sort_by) && !subCall
			puts 'SORT All Subs End Result'
			if !by_mgr
				@return.sort!{|a,b| a.name.downcase <=> b.name.downcase}
			else
				@return
			end
		end
		puts @return.map{|m| m.name}
		@return
		#@return.sort_by! {|a| [a.manager.name, a.name]}
		
	end
	
	def all_subs_by_id(mid)
		@m = User.find(mid)
		@return = Array.new()
		puts "MANAGER IS-" + @m.name
		if @m.subordinates.any?
			# puts "-FOUND SUBORDINATES"
			@exId = User.find_by_name("ExEmployeeMgr").id
			@subs = @m.subordinates.select(:id).where('id != ?', @exId)
			@return = @subs.to_a
			# puts "Return Length - " 
# 			puts @return.length
			@m.subordinates.each do |s|
				if s.subordinates.any?
					puts "---FOUND Sub-SUBORDINATES"	
					@return |= all_subs_by_id(s.id)
					#puts @return.to_s
				end
			end
			@return
		else
			#puts @return.to_s
			@return
		end
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
	
	def period_from_date(d)
		@sPeriod = 0.0
		@fyear = d.year
		puts "in period_from_date"
		if d.mon == 12 then
			@fyear = @fyear + 1
			@sPeriod = d.cweek + 4 - 52
		else
			#puts 'IN ELSE'
			@sPeriod += d.cweek + 4.0
		end
		# puts "sPeriod is:"
# 		puts @sPeriod
		@out = @fyear + @sPeriod.fdiv(100).round(3)
		puts "period from date"
		puts d.to_s
		puts @out
		@out
	end
	
	def current_period()
	# ToFix
		@cweek_number = 0.0
		@fyear = Date.today.year 
		if Date.today.mon == 12 then
			@fyear = @fyear + 1
			@cfy_offset = 4 #SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
			@cweek_number = Date.today.cweek + @cfy_offset - 52
		else
			@cfy_offset = 4 #SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
			@cweek_number = Date.today.cweek + @cfy_offset
		end
		#puts 'CURRENT CWEEK Number: '
		#puts  @cweek_number
		@out = @fyear + @cweek_number.fdiv(100).round(3)
		puts 'cPeriod ='
		puts @out
		@out
		#SetPeriod.where(:fiscal_year => @fyear, :week_number => @cweek_number).first
	end
	
	
	
	def period_list()
	#ToReview
		if current_user.admin? then
			l = SetPeriod.all
		else
			l = SetPeriod.where("id >= " + current_period().id.to_s).all	
		end
	end
	
end
