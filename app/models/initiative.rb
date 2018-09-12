class Initiative < ActiveRecord::Base
has_many :projects
serialize :subprilist
  	
scope :active, -> {where('active = true')}
scope :for_year, -> (y){where("fiscal = ? or name IN('Overhead','Basics')", y)}

	def total_effort_weeks(cWeek)
		@ytd_weeks = 0
		fy = self.cfiscal
		self.projects.for_year(fy).each do |proj|
			@ytd_weeks += proj.ytd_allocation(fy, cWeek)
		end
		@ytd_weeks.round(1)
	end
	
	def current_effort_weeks(pid)
		@c_weeks = 0
		fy = self.cfiscal
		puts "current_effort_weeks for initiative for week: ?", pid.to_s
		self.projects.for_year(fy).each do |proj|
			@c_weeks += proj.assignments.where("set_period_id = ?", pid).sum("effort")
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
end
