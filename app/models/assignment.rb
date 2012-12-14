class Assignment < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :project, :foreign_key => "project_id"
  belongs_to :set_period, :foreign_key => "set_period_id"
  attr_accessible :effort, :set_period, :set_period_id, :is_fixed, :project_id, :user_id, :user, :project
end
