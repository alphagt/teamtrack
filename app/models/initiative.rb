class Initiative < ApplicationRecord
has_many :projects
serialize :subprilist
  	
scope :active, -> {where('active = true')}
scope :for_year, -> (y){where("fiscal = ? or name IN('Overhead','Basics')", y)}
scope :for_account, -> (aid){where('account_id = ?', aid)}

	def total_effort_weeks(cWeek)
		@ytd_weeks = 0
		fy = self.cfiscal
		self.projects.for_year(fy).each do |proj|
			@ytd_weeks += proj.ytd_allocation(fy, cWeek)
		end
		@ytd_weeks.round(1)
	end
	
	def current_effort_weeks(pid, fullQ = false)
		@c_weeks = 0
		fy = self.cfiscal
		puts "current_effort_weeks for initiative for week: ?", pid.to_s
		if fullQ 
			qWeeks = ApplicationController.helpers.qWeekRange(pid)
			sWeek = fy.to_i + (qWeeks[0]-1).fdiv(100).round(3)
			eWeek = fy.to_i + (qWeeks[1]+1).fdiv(100).round(3)
			self.projects.for_year(fy).each do |proj|
				@c_weeks += proj.assignments.where("set_period_id Between ? AND ?",sWeek,eWeek).sum("effort")
			end
		else
			self.projects.for_year(fy).each do |proj|
				@c_weeks += proj.assignments.where("set_period_id = ?", pid).sum("effort")
			end
		end
		@c_weeks.round(1)
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
