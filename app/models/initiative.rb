class Initiative < ActiveRecord::Base
has_many :projects
  	
scope :active, -> {where('active = true')}
scope :current_year, -> {where('fiscal = 2017')}

	def total_effort_weeks
		@ytd_weeks = 0
		self.projects.each do |proj|
			@ytd_weeks += proj.ytd_allocation
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
