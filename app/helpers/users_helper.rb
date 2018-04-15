module UsersHelper

	def current_project(cuser, tperiod = current_period)
		@cperiod = tperiod
# 		puts "current_project funct - C Period is:"
# 		puts @cperiod
		@rStr = ""
		if cuser.projects.length > 0 then
			@return = cuser.assignments.where(:set_period_id => @cperiod)
			@return.each do |proj|
			 	@rStr = @rStr + proj.project.name + '(' + proj.effort.to_s + ')' + ', '
			end
		end
		
# 		puts 'Count of current ASSIGNMENTS:'
# 		puts @return.length
		
		@rStr.chomp(", ")
	end
	
	def current_system(cuser, tperiod = current_period)
		@rStr = ""
		if cuser.tech_systems.length > 0 then
			@return = cuser.assignments.where(:set_period_id => tperiod)
			@return.each do |a|
				if !a.tech_system.blank?
					@rStr += a.tech_system.name + ', '
				end
			end
		end
		@rStr.chomp(", ")
	end
	
	def current_assignment(cuser, speriod = current_period)
		if cuser.assignments.where("set_period_id = ?", speriod).length > 0
			cuser.assignments.where(:set_period_id => speriod)
		else
			Array.new()
		end
	end
	
	def current_subordinates_assigned(mid, speriod = current_period)
		iout = 0
		User.find(mid).subordinates.each do |s|
			if s.assignments.where("set_period_id =?", speriod).length > 0 
				iout += 1
			end
		end
		iout
	end
	
	def latest(cuser, floor = 0)
		if cuser.assignments.where("set_period_id >= ?", floor).length > 0
			@latest = cuser.assignments.where("set_period_id >= ?", floor).order("set_period_id DESC").first.set_period_id	
			cuser.assignments.where(:set_period_id => @latest)
		else
			Array.new()
		end
	end
	
	def latestInfoStr(cuser)
		@str = ""
		tweek = ""
		if cuser.assignments.length > 0
			@latest = cuser.assignments.order("set_period_id DESC").first.set_period_id	
			cuser.assignments.where(:set_period_id => @latest).each do |a|
				@rStr = @rStr + a.project.name + '(' + a.effort.to_s + ')' + ', '
			end
			w = week_from_period(@latest)
			if w < 52 then
				tweek = w + 1
			else
				tweek = (w + 1) - 52
			end
		end
		@rStr.chomp(", ") + " to week: " + tweek.to_s
	end
	
	def extended_subordinates(mid, noBlock=false, showEx=false, tperiod=current_period())
		a_subs = Array.new()
		m = User.find(mid)
		a_subs += [m]
		xid = 0
		if !showEx then
			xid = User.find_by_name("ExEmployeeMgr").id
		end
		a_subs += all_subs(mid, showEx)
		
		if !noBlock then 
			a_subs_block = view_user_block(a_subs, false, tperiod)
		else
			a_subs_block = a_subs
		end
		puts "AllSubs:  #{a_subs.map{|u| u.name}}"
		#determin list of orgs to include (any owned by self or subs)
		org_list = m.subordinates.where("orgowner = true").pluck(:org)
		org_list += [m.org]
		puts "Org List" + org_list.to_s
		b_subs = User.where("manager_id IS NOT NULL AND manager_id != ? AND org IN (?) AND id not in(?)", 
			xid, org_list, a_subs.map{|u| u.id}).order('manager_id')
		b_subs.delete(m)
		if !noBlock then b_subs = view_user_block(b_subs.uniq, true,tperiod) end
		#puts "Non-Sub Org Members:  #{b_subs.map{|u| u.name}}"
		a_out = (a_subs_block + b_subs).uniq
		#puts "ExtendedSubs Count IS:  #{a_out.count}"
		#puts a_out.map{|u| u.name}
		a_out
	end
	
	def view_user_block(ulist, areIndirect, tperiod)
		a_out = Array.new()
		previous = ulist.first
		level = 0
		csys = ""
		cproj = ""
		ulist.each do |u|
			if u.manager == previous then
				level += 1
				previous = u.manager
			end
			if u.subordinates.length == 0 then
				#csys =  current_system(u, tperiod)
				#cproj = current_project(u, tperiod)
				a_out << [0, areIndirect, u, csys, cproj]
			end
		end	
		puts a_out.to_s
		a_out
	end
	
	def subs_assignment_stats_string(m)
		sout = " ("
		sout +=  current_subordinates_assigned(m.id).to_s + "/" + m.subordinates.length.to_s + ")"
		sout
	end
	
	def get_org(mid, org = nil, hold = [], ind = false)
		#Generates an org info array in form [[list of all manager ids], number of IC FTE, number of IC Contractors, [list of direct report managers]]
		ret = hold
		m = User.find(mid)
		puts "Get Org for " + m.name
		puts "   Start Array " + ret.to_s
		if org.nil? || ind
			subs = m.subordinates
			org = m.org
		else
			subs = m.subordinates
		end
		if ret.count == 0
			#add top level manager to list
			ret += [[mid],0,0,[mid]]
		end
		#add current user data to existing hash
		#ret[0] += subs.managers_only.pluck(:id)
		ret[1] += subs.fte_only.count
		ret[2] += subs.contract_only.count
		
		#recurse through subordinate managers
		subs.managers_only.each do |u|
			ret[0] += [u.id]
			if !ind
				ret[3] += [u.id]
			end
			ret = get_org(u.id, org, ret, ind)
		end
		
		#identify indirect managers to add to list
		if m.orgowner
			target_org = m.org
			puts "   BRANCH FOR INDIRECT ORG:  " + target_org
			isubs = User.where("users.org = ?", target_org).managers_only
			#identify just the 'top-level' indirect managers
			isubs.each do |i|
				if !ret[0].include? i.id
					if i.manager.nil? || !isubs.include?(i.manager)
						#this is a top level indirect mgr
						puts "ADD INDR TOP LEVEL MGR: " + i.name
						#add to mgr list and count
						ret[0] += [i.id]
						#ret[1] += 1 #to account for the manager themselves
						#recurse for this manager
						ret = get_org(i.id, target_org, ret, true)
					end
				end
			end
		end
		puts "   END ARRAY " + ret.to_s
		ret
	end
	
end
