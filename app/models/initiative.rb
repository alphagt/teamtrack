class Initiative < ApplicationRecord
has_many :projects
has_many :assignments
serialize :subprilist
  	
scope :active, -> {where('active = true')}
#scope :for_year, -> (y){where("(fiscal = ? or name IN('Overhead','Basics')", y)}
scope :for_year, -> (fy){joins(:assignments).where("assignments.set_period_id between ? and ?", fy, (fy + 1)).distinct}
scope :for_weeks, -> (s,f){joint(:assignments).where("assignments.set_period_id between ? and ?", s, f).distinct}
scope :for_account, -> (aid){where('account_id = ?', aid)}

	def total_effort_weeks(cWeek, fy = self.cfiscal)
		@ytd_weeks = 0
		puts "TEW FY:  " + fy.to_s
		@newTotal = Assignment.for_initiative(self.id).ytd(fy.to_i + cWeek.fdiv(100).round(3)).sum(:effort)
		#puts "TEST-" + self.tag + ":  " + @newTotal.to_s
		#Old Impl - Deprecated
		# self.projects.for_year(fy).each do |proj|
# 			@ytd_weeks += proj.ytd_allocation(fy, cWeek)
# 		  end
# 		  @ytd_weeks.round(1)
		@newTotal.round(1)
	end
	
	def current_effort_weeks(pid, fullQ = false)
		@new_c_weeks = 0.0
		fy = pid.to_i
		puts "current_effort_weeks for initiative for week: " + pid.to_s
		if fullQ 
			qWeeks = ApplicationController.helpers.qWeekRange(pid)
			sWeek = fy + (qWeeks[0]-1).fdiv(100).round(3)
			eWeek = fy + (qWeeks[1]+1).fdiv(100).round(3)
			@new_c_weeks = Assignment.for_initiative(self.id).where("set_period_id BETWEEN ? AND ?",sWeek,eWeek).sum(:effort)
			# puts "TEST-" + self.tag + ":  " + @new_c_weeks.round(1).to_s
# 			self.projects.for_year(fy).each do |proj|
# 				e = proj.assignments.where("set_period_id Between ? AND ?",sWeek,eWeek).sum("effort")
# 				@c_weeks += e
# 				#puts "Add inscope weeks: " + proj.name + " - " + e.to_s 
# 			end
			puts "Full Quarter - Effort Weeks for " + sWeek.to_s + " to " + eWeek.to_s
			puts @new_c_weeks.round(1).to_s
		else
			@new_c_weeks = Assignment.for_initiative(self.id).recent(pid).sum(:effort)
# 			self.projects.for_year(fy).each do |proj|
# 				@c_weeks += proj.assignments.where("set_period_id = ?", pid).sum("effort")
# 			end
		end
		@new_c_weeks.round(1)
	end
	
	def cfiscal
		if self.fiscal.nil? then
			
			Date.today.year
		else
			self.fiscal
		end
	end
	
#  ------ Deprecated, moved to application helper -----
	# def qWeekRange(pid)
# 		@cw = ((pid - pid.to_i)*100).round
# 		puts "Week Range PID = " + @cw.to_s
# 		case 
# 		when @cw <= 13
# 			wRange = [1,13]
# 		when 13 < @cw && @cw <= 25
# 			wRange = [13,26]
# 		when 25 < @cw && @cw <= 37
# 			wRange = [25,38]
# 		when @cw > 37
# 			wRange = [38,52]
# 		end
# 		
# 		wRange
# 	end
end
