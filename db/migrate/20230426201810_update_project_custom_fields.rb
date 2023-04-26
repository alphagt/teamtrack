class UpdateProjectCustomFields < ActiveRecord::Migration[5.2]
  def up
  	Account.all.each do |a|
		set = Setting.create!  :account_id => a.id, :stype => 0, :key => 'p_cust_6', :value => "team", :displayname => 'Team',
				:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
					picklist values can be added to settings with p_cust_6 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		
		set = Setting.create!  :account_id => a.id, :stype => 0, :key => 'p_cust_7', :value => "end_date", :displayname => 'ShipDate',
				:description => 'Custom field for project end_date.  Admin can define visible name by setting displayname on this setting.'
		set.save
		puts 'added ' << set.key
	end
  end
end
