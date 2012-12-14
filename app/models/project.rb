class Project < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  has_many :assignments
  has_many :users, :through => :assignments
  attr_accessible :owner, :active, :description, :name, :owner_id
end
