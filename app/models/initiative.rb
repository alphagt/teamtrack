class Initiative < ActiveRecord::Base
has_many :projects
  	
scope :active, -> {where('active = true')}
scope :for_year, -> (y){where("fiscal = ? or name IN('Overhead','Basics')", y)}

	def total_effort_weeks(cWeek)
		@ytd_weeks = 0
		fy = self.fiscal
		self.projects.each do |proj|
			@ytd_weeks += proj.ytd_allocation(fy, cWeek)
		end
		@ytd_weeks.round(1)
	end
	
	def current_effort_weeks(pid)
		@c_weeks = 0
		puts "current_effort_weeks for initiative for week: ?", pid.to_s
		self.projects.each do |proj|
			@c_weeks += proj.assignments.where("set_period_id = ?", pid).sum("effort")
		end
		@c_weeks.round(1)
	end
end
