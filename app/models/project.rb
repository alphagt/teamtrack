class Project < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :assignments, -> { order "set_period_id" }
  has_many :users, -> { order "name" }, :through => :assignments
  attr_accessible :owner, :active, :description, :category, :name, :owner_id, :fixed_resource_budget, :upl_number
	

	scope :for_users, -> (uList){joins(:users).where('assignments.user_id IN (?)', uList).distinct}
	scope :active, -> {where('active = true')}
	
	def under_budget(pId)
		tEffort = 0
		assignments.where(:set_period_id => pId).each do |a|
			tEffort += a.effort
		end
		fixed_resource_budget > tEffort
	end
end
