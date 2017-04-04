class Project < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :assignments
  has_many :users, -> { order "users.name" }, :through => :assignments
  attr_accessible :owner, :active, :description, :category, :name, :owner_id, :fixed_resource_budget, :upl_number
  #default_scope {order("projects.name")}

  validates :fixed_resource_budget, :presence => true
   
	scope :for_users, -> (uList){joins(:users).where('assignments.user_id IN (?)', uList).distinct}
	scope :active, -> {where('active = true')}
	scope :by_name, -> {order('projects.name')}
	scope :by_category, -> {order('projects.category','projects.name')}
	
	def under_budget(pId)
		tEffort = 0
		assignments.where(:set_period_id => pId).each do |a|
			tEffort += a.effort
		end
		fixed_resource_budget > tEffort
	end
end
