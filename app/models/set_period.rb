class SetPeriod < ActiveRecord::Base
  has_many :assignment
  attr_accessible :cweek_offset, :fiscal_year, :week_number, :period_name
  
  def period_name
  	self.fiscal_year.to_s + "-" + self.week_number.to_s
  end
end
