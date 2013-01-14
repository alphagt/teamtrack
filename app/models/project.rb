class Project < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :assignments, :order => "set_period_id DESC"
  has_many :users, :through => :assignments, :order => "name ASC"
  attr_accessible :owner, :active, :description, :name, :owner_id, :fixed_resource_budget
end
