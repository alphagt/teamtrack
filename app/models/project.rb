class Project < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :assignments, :order => "set_period_id DESC"
  has_many :users, :through => :assignments, :order => "name ASC"
  attr_accessible :owner, :active, :description, :name, :owner_id, :fixed_resource_budget

	def under_budget(weekid)
		tEffort = 0
		assignments.where(:set_period_id => weekid).each do |a|
			tEffort += a.effort
		end
		fixed_resource_budget > tEffort
	end
end
