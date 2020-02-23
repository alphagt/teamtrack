class Account < ApplicationRecord
	belongs_to :primary_admin, :class_name => "User"
	belongs_to :secondary_admin, :class_name => "User"
end
