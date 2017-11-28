class TechSystem < ActiveRecord::Base
	belongs_to :owner, :class_name => 'User'
	has_many :assignments, -> { order "set_period_id" } 
	attr_accessible :owner, :name, :description, :qos_group,:owner_id
	#default_scope {order("name")}
	
	scope :by_qos, -> {order('qos_group, name')}
	scope :by_name, -> {order('name')}
	
	def average_assigned(fy, wk)
		x = Assignment.where("tech_sys_id = ? AND set_period_id > ?", self.id, fy.to_d).sum("effort")
		@avg = (x.to_d/wk).round(1)
	end
	
end
