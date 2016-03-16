class Assignment < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :project, :foreign_key => "project_id"
  attr_accessible :effort, :set_period_id, :is_fixed, :project_id, :user_id, :user, :project
  validates :project_id, :presence => true
  validates :user_id, :presence => true
  validates :effort, :presence => true, :numericality => { :greater_than => 0 }
  validate :total_effort_max
  validate :one_assg_per_project_week, :on => :create
    
  def self.extend_by_week(cAssign)
  #ToFix
  		@pFy = cAssign.set_period_id.to_i
		@fWeek = ((cAssign.set_period_id - @pFy) * 100).round 
		puts @fWeek
		if @fWeek < 52
  			n = Assignment.new({:is_fixed => cAssign.is_fixed, :project_id => cAssign.project_id, :user_id => cAssign.user_id, :set_period_id => cAssign.set_period_id + 0.01, :effort => cAssign.effort})
  		else
  			n = Assignment.new({:is_fixed => cAssign.is_fixed, :project_id => cAssign.project_id, :user_id => cAssign.user_id, :set_period_id => cAssign.set_period_id + 0.49, :effort => cAssign.effort})
  		end
  		if n then
			if n.project.under_budget(n.set_period_id) == false then
				n.is_fixed = false
			end
			puts 'CLONE PERIOD:'
			n.set_period_id = n.set_period_id.round(2)
			puts n.set_period_id
			n.save
		else
			errors.add(:extend, "Unable to copy assignment to next period")
		end
  end
  
  def total_effort_max
  	#verify all assignments in this week for this user have total effort < 1
	tEffort = 0
  	if effort then tEffort = effort end
  	Assignment.where(:user_id => user_id, :set_period_id => set_period_id).each do |a|
  		if a != self
  			tEffort += a.effort
  		end
  	end
  	puts "Effort Validator"
  	puts tEffort
  	errors.add(:effort, "Total effort of all assignments this week for selected resource > 1") unless tEffort <= 1
  end
  
  def one_assg_per_project_week
  	errors.add(:project_id, "Assignment to this project for this week already exists, modify existing assignment") unless 
  		Assignment.where(:user_id => user_id, :set_period_id => set_period_id, :project_id => project_id).count == 0
  end
end
