class SetPeriod < ApplicationRecord
  has_many :assignment, -> {order "set_period_id DESC"}
  attr_accessible :cweek_offset, :fiscal_year, :week_number, :period_name, :id
  
  def period_name
  	if self.week_number > self.cweek_offset then
			Date.commercial(self.fiscal_year,self.week_number - self.cweek_offset,1)
		else
			Date.commercial(self.fiscal_year - 1,self.week_number - self.cweek_offset - 1,1)
		end
  end
end
