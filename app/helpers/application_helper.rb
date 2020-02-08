module ApplicationHelper
	def period_to_date(speriod)
		@cweek_number = 0.0
		
		@fyear = speriod.to_i
		@cfy_offset = display_name_for('sys_names', 'fy offset').to_i * -1
	
		if @cfy_offset == 0 then
			@offset_y_adjust = 0
		else
			@offset_y_adjust = @cfy_offset/@cfy_offset.abs
		end
		@cweek_number = ((speriod.to_f - speriod.to_i) * 100).round
# 		puts 'in period_to_date'
# 		puts speriod
# 		puts 'period week number is:'
# 		puts @cweek_number
# 		puts 'Offset is'
# 		puts @cfy_offset
		#handle special case at start or end of calendar year
		if @cweek_number <= @cfy_offset || @cweek_number > (52 + @cfy_offset) then
			@fyear = @fyear - @offset_y_adjust
			@cweek_number = (52 - (@cfy_offset - @cweek_number).abs).abs
		else
			@cweek_number = @cweek_number - @cfy_offset
		end
# 		puts 'real week num is'
# 		puts @cweek_number
		Date.commercial(@fyear, @cweek_number, 1)
	#ToFix
# 		@pPeriod = speriod.to_f
# 		#puts @pPeriod.to_s
# 		@fyOffset = display_name_for('sys_names', 'fy offset').to_i
# 		puts "FY OFFSET FROM C FIELDS"
# 		puts @fyOffset
# 		@pFy = speriod.to_i
# 		@fWeek = ((@pPeriod - @pFy) * 100).round
# 		#puts @fWeek
# 		if @fWeek <= @fyOffset
# 			@pFy -= 1
# 			@cWeek = 52 - (@fyOffset - @fWeek)
# 		else
# 			@cWeek = @fWeek - @fyOffset
# 		end
# 		Date.commercial(@pFy,@cWeek,1)
	end

	def period_from_parts(iFy, iWeek)

 		#puts 'period_from_parts'
 		#puts 'iWeek'
 		# @fWeek = 0.0
 		puts iWeek
		@fWeek = iWeek.to_i
		puts @fWeek.to_s
		@return = iFy.to_i + @fWeek.fdiv(100).round(3)
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
# 		@fyOffset = display_name_for('sys_names', 'fy offset').to_i
		@cw = current_week()
# 		if @cw > (52 - @fyOffset) then
# 			@cw = @cw + @fyOffset - 52
# 		else
# 			@cw += @fyOffset
# 		end
		@q = 0
		case 
		when @cw < 13
			@q = 1
		when 12 < @cw && @cw < 25
			@q = 2
		when 24 < @cw && @cw < 37
			@q = 3
		when @cw > 36
			@q = 4
		end
		@q		
	end
	
	def all_subs(mid, showEx = false, subCall = false, by_mgr = true)
		@m = User.find(mid)
		@return = Array.new()
# 		puts 'all_subs helper'
# 		puts "MANAGER IS-" + @m.name
# 		puts "showEx is-" + showEx.to_s
# 		puts "subCall is-" + subCall.to_s
# 		puts "by_mgr is-" + by_mgr.to_s
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
		#			puts "---FOUND Sub-SUBORDINATES"
		#			puts s.name	
					@return |= all_subs(s.id, false, true)
					#puts @return
				end
			end
			# add exManager reports if indicated
			if showEx && !subCall then
				@return |= all_subs(@exId, true, true, by_mgr)
			end
			if @return.respond_to?(:order)
		#		puts "--- list is in active record form"
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
# 			puts 'SORT All Subs End Result'
			if !by_mgr && @return.respond_to?(:sort!)
				@return.sort!{|a,b| a.name.downcase <=> b.name.downcase}
			else
				@return
			end
		end
# 		puts @return.map{|m| m.name}
		@return
		#@return.sort_by! {|a| [a.manager.name, a.name]}
		
	end
	
	def all_subs_by_id(mid, bExtend = false)
		m = User.find(mid)
		a_return = Array.new()
		if !bExtend 
			#puts "MANAGER IS-" + @m.name
			if m.subordinates.any?
				# puts "-FOUND SUBORDINATES"
				exId = User.find_by_name("ExEmployeeMgr").id
				subs = m.subordinates.select(:id).where('id != ?', exId)
				a_return = subs.to_a
				# puts "Return Length - " 
	# 			puts @return.length
				m.subordinates.each do |s|
					if s.subordinates.any?
			#			puts "---FOUND Sub-SUBORDINATES"	
						a_return |= all_subs_by_id(s.id)
						#puts @return.to_s
					end
				end
				puts "Found " + a_return.length.to_s + " Subordinates for " + User.find(mid).name
				a_return
			else
	# 			puts @return.to_s
				a_return
			end
		else
			ex_subs = extended_subordinates(mid)
			if ex_subs.any?
				a_return = ex_subs.map{|u| u[2].id}.to_a
				puts "Found " + a_return.length.to_s + " Subordinates for " + User.find(mid).name
				a_return 
			else
				a_return
			end
		end
	end
	
	
	
	def free_next_week(cuser, cp = current_period)
		rcode = true
		if cuser.assignments.length > 0
			foo = cp + 0.01
# 				puts "TEST PERIOD: " + foo.to_s
			if cuser.assignments.where(:set_period_id => foo).sum("effort") == 1
				rcode = false
			end
		end
		rcode
	end
	
	def extend_team(mUser, floor = 0)
		rcode = 0
		mUser.subordinates.each do |u|
			latest(u,floor).each do |a|
				if Assignment.extend_by_week(a) then
					rcode += 1
				end
			end
		end
		rcode
	end
	
	def period_from_date(d, offset = 53)
		# @sPeriod = 0.0
# 		@fyear = d.year
# 		@fyOffset = display_name_for('sys_names', 'fy offset').to_i
# 		
# 		#puts "in period_from_date"
# 		if d.cweek > (52 - @fyOffset) then
# 			@fyear = @fyear + 1
# 			@sPeriod = d.cweek + @fyOffset - 52
# 		else
# 			#puts 'IN ELSE'
# 			@sPeriod += d.cweek + @fyOffset.to_f
# 		end
# 		# puts "sPeriod is:"
# # 		puts @sPeriod
# 		@out = @fyear + @sPeriod.fdiv(100).round(3)
		@out = offset_period(d, offset)
		#puts "period from date"
		#puts d.to_s
		#puts @out
		@out
	end
	
	def current_period()
		# @cweek_number = 0.0
# 		@fyear = Date.today.year 
# 		@cfy_offset = display_name_for('sys_names', 'fy offset').to_i
# 		@offset_y_adjust = @cfy_offset/@cfy_offset.abs
# 		puts 'Offset is'
# 		puts @cfy_offset
# 		if Date.today.cweek <= @cfy_offset || Date.today.cweek > (52 + @cfy_offset) then
# 			@fyear = @fyear + @offset_y_adjust
# 			@cweek_number = (52 - (@cfy_offset - Date.today.cweek).abs).abs
# 		else
# 			@cweek_number = Date.today.cweek - @cfy_offset
# 		end
# 		puts 'CURRENT CWEEK Number: '
# 		puts  @cweek_number
# 		@out = @fyear + @cweek_number.fdiv(100).round(3)
		@out = offset_period(Date.today)
		puts 'cPeriod ='
		puts @out
		@out
		#SetPeriod.where(:fiscal_year => @fyear, :week_number => @cweek_number).first
	end
	
	def offset_period(d, hardOffset = 53)
		@cweek_number = 0.0
		@fyear = d.year 
		if hardOffset == 53 then
			@cfy_offset = display_name_for('sys_names', 'fy offset').to_i
		else
			@cfy_offset = hardOffset
		end
		if @cfy_offset == 0 then
			@offset_y_adjust = 0
		else
			@offset_y_adjust = @cfy_offset/@cfy_offset.abs
		end
		# puts 'Offset is'
# 		puts @cfy_offset
		#handle special case at start or end of calendar year
		if d.cweek <= @cfy_offset || d.cweek > (52 + @cfy_offset) then
			@fyear = @fyear - @offset_y_adjust
			@cweek_number = (52 - (@cfy_offset - d.cweek).abs).abs
		else
			@cweek_number = d.cweek - @cfy_offset
		end
		@out = @fyear + @cweek_number.fdiv(100).round(3)
	end
	
	def period_list()
	#ToReview
		if current_user.admin? then
			l = SetPeriod.all
		else
			l = SetPeriod.where("id >= " + current_period().id.to_s).all	
		end
	end
	
	def fy_list(option_all = true)
		@list = []
		if option_all
			@list << "All"
		end
		if Assignment.count > 0 
			min_y = Assignment.find_by_id(Assignment.all.select("id, min(set_period_id)").first.id).fiscal_year()
		else
			min_y = current_fy
		end
		puts "MIN FY IS:  "
		puts min_y
		@list << min_y
		while min_y < current_fy do
			min_y += 1
			@list << min_y
		end
		puts @list
		@list
	end
	
	def w_list()
		@list = ('1' .. '52').to_a
	end
	
	def get_picklist(key, proj = nil, showval = false)
		if key == "core" then
			if !showval then
				Setting.core_only.pluck(:value)
			else
				Setting.core_only.pluck(:displayname,:value)
			end
		else
			puts "Get_Picklist for key: " + key
			if key == 'priority' && !proj.nil? && proj.initiative.present?
				#get the list for this key based on the associated initiative's subprilist
				proj.initiative.subprilist
			else
				s = Setting.for_key(key)
				if s.length > 0 then
					subKey = Setting.for_key(key).first.value	
				else
					subKey = key
				end
				if !showval then
					Setting.for_key(subKey).pluck(:displayname)
				else
					Setting.for_key(subKey).pluck(:displayname,:value)
				end
			end
		end
	end	
	
	def get_cfield_name(key)
		s = Setting.find_by_key(key)
		if s.stype == 0 then
			s.displayname
		end
	end
	
	def org_mgrs_list(option_all = true)
		@list = []
		if option_all
			@list << ["All", 0]
		end
		User.managers_only.where("orgowner = true").each do  |u|
			if u.manager.nil? || !u.manager.orgowner
				if u.name.length > 18 then
					puts "TRUNCATING ORG OWNER NAME"
					tname = u.name.truncate(18)
				else
					tname = u.name
				end
				@list <<  [tname + " (" + u.org + ")", u.id]
			end
		end	
		@list
	end
	
	def orgs_hash()
		ohash = Hash.new
		User.managers_only.where("orgowner = true").each do  |u|
			if u.manager.nil? || !u.manager.orgowner
				ohash[u.org] = u.name
			else
				ohash[u.org] = u.manager.name
			end
		end	
		ohash
	end
	
end
