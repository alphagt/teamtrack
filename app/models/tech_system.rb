class TechSystem < ActiveRecord::Base
	belongs_to :owner, :class_name => 'User' 
	attr_accessible :owner, :name, :description, :qos_group,:owner_id
end
