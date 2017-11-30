module TechSystemsHelper

	def qos_average_effort(qos_group)
		sList = TechSystem.for_qos(qos_group).pluck(:id)
		x = Assignment.where("tech_sys_id IN(?) AND set_period_id > ?", sList, current_fy.to_d).sum("effort")
		@avg = (x.to_d/current_week).round(1)
		
	end
end
