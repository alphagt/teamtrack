class TechSystem < ActiveRecord::Base
	belongs_to :owner, :class_name => 'User'
	has_many :assignments, -> { order "set_period_id" } 
	attr_accessible :owner, :name, :description, :qos_group,:owner_id
end
