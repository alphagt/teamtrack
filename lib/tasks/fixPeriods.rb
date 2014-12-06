#!/usr/bin/env ruby

Assignment.each.do |a|
	@oldPeriod = SetPeriod.find_by_id(a.set_period_id)
	if a.set_period.id > 2000 then
		@newPeriod = @oldPeriod.fiscal_year.to_f + (@oldPeriod.week_number.to_f / 100)
		a.set_period_id = @newPeriod
		a.save
	end
end
