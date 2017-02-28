class TechSystem < ActiveRecord::Base
	belongs_to :owner, :class_name => 'User'
	has_many :assignments, -> { order "set_period_id" } 
	attr_accessible :owner, :name, :description, :qos_group,:owner_id
	#default_scope {order("name")}
	
	scope :by_qos, -> {order('qos_group, name')}
	scope :by_name, -> {order('name')}
	
end
