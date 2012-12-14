module AssignmentsHelper

	def to_date(speriod)
		if speriod.week_number > speriod.cweek_offset then
			Date.commercial(speriod.fiscal_year,speriod.week_number - speriod.cweek_offset,1)
		else
			Date.commercial(speriod.fiscal_year - 1,speriod.week_number - speriod.cweek_offset - 1,1)
		end
	end
end
