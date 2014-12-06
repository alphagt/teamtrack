class ChangeSetPeriodIdType < ActiveRecord::Migration

  def up
  	change_column :assignments, :set_period_id, :float
  	
  	Assignment.all.each do |a|
		if a.set_period_id < 2000 then
			@oldPeriod = SetPeriod.find_by_id(a.set_period_id.to_i)
			if @oldPeriod != nil then
				@newPeriod = @oldPeriod.fiscal_year.to_f + (@oldPeriod.week_number.to_f / 100)
				a.set_period_id = @newPeriod
				puts "Updating Assignment ..."
				puts a.id
				a.save
			end
		end
  	end
  end
  
  
end
