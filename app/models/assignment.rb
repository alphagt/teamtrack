class Assignment < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :project, :foreign_key => "project_id"
  belongs_to :set_period, :foreign_key => "set_period_id"
  attr_accessible :effort, :set_period, :set_period_id, :is_fixed, :project_id, :user_id, :user, :project
  validate :total_effort_max
  validate :one_assg_per_project_week, :on => :create
    
  def self.extend_by_week(cAssign)
  		n = Assignment.new({:project_id => cAssign.project_id, :user_id => cAssign.user_id, :set_period_id => cAssign.set_period_id + 1, :effort => cAssign.effort})
  		puts 'CLONE PERIOD:'
  		puts n.set_period_id
  		n.save
  end
  
  def total_effort_max
  	#verify all assignments in this week for this user have total effort < 1
  		tEffort = effort
  	Assignment.where(:user_id => user_id, :set_period_id => set_period_id).each do |a|
  		if a != self
  			tEffort += a.effort
  		end
  	end
  	puts "Effort Validator"
  	puts tEffort
  	errors.add(:effort, "Total effort of all assignments this week > 1") unless tEffort <= 1
  end
  
  def one_assg_per_project_week
  	errors.add(:project_id, "Assignment to this project for this week already exists, modify existing assignment") unless 
  		Assignment.where(:user_id => user_id, :set_period_id => set_period_id, :project_id => project_id).count == 0
  end
end
