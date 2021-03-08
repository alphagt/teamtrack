class Account < ApplicationRecord
	belongs_to :primary_admin, :class_name => "User"
	belongs_to :secondary_admin, :class_name => "User"
	has_many :invitecodes, :class_name => "InviteCode", :foreign_key => "account_id"
end
