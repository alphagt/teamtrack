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
		@fWeek = iWeek.to_f / 100
		#puts @fWeek
		@fWeek
	end
	
	def all_subs(mid)
		@m = User.find(mid)
		@return = Array.new()
		puts "MANAGER IS-" + @m.name
		if @m.subordinates.any?
			# puts "-FOUND SUBORDINATES"
			@exId = User.find_by_name("ExEmployeeMgr").id
			@return = @m.subordinates.where('id != ?', @exId).order(:name)
			# puts "Return Length - " 
# 			puts @return.length
			@m.subordinates.each do |s|
				if s.subordinates.any?
					puts "---FOUND Sub-SUBORDINATES"	
					@return |= all_subs(s.id)
					puts @return
				end
			end
			if @return.respond_to?(:order)
				puts "--- list is in active record form"
				@return.order(:manager_id, :name)
			else
				@return
			end
		else
			@return
		end
		
		#@return.sort_by! {|a| [a.manager.name, a.name]}
		
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
		puts d.to_s
		puts @fyear
		if d.mon == 12 then
			@fyear = @fyear + 1
			@sPeriod = d.cweek + 4 - 52
		else
			sPeriod = d.cweek + 4
		end
		puts "sPeriod is:"
		puts @sPeriod
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
