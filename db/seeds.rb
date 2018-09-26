case Rails.env


when "development"
#Default User
puts 'SETTING UP DEFAULT USER LOGIN'
@suser = User.create! :name => 'System Admin', :email => 'sysadmin@teamtrack.com', :admin => true, :verified => true, :password => 'password', :password_confirmation => 'password'
@suser.save
puts 'New user created: ' << @suser.name
proj = Project.create! :name => 'Maintenance/Tech Debt', :active => true, :owner => @suser, :description => 'Bug fix, Tech Debt, Ops Improvements', :tribe => 'All', :category => 'HQA', :fixed_resource_budget => 15
proj.save
puts 'added maintenance project'
proj = Project.create! :name => 'Security-Compliance Maintenance', :active => true, :owner => @suser, :description => 'Bug fixes and small sec/comp work items', :tribe => 'All', :category => 'Sec/Comp', :fixed_resource_budget => 10
proj.save
puts 'added security compliance project'
proj = Project.create! :name => 'Run the Business', :active => true, :owner => @suser, :description => 'Operations and minor enhancements', :tribe => 'All',  :category => 'RTB', :fixed_resource_budget => 30
proj.save
puts 'added RTB Project'

#test users
user = User.create! :name => 'Test User', :email => 'test@adobe.com', :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
#user['manager_id'] = 1
user.manager = @suser
user.save
puts 'New user created: ' << user.name
user = User.create! :name => 'ExEmployeeMgr', :email => 'test2@adobe.com', :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
user['manager_id'] = 1
user.save
puts 'New user created: ' << user.name

#test Systems
sys = TechSystem.create! :name => 'Management Overhead', :description => 'System for Managers of multiple service teams', 
	:qos_group => 'NA', :owner_id => 1
sys.save
puts 'added default system for managers'
sys = TechSystem.create! :name => 'Test System 1', :description => 'Some system description', 
	:qos_group => 'GroupA', :owner_id => 1
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Test System 2', :description => 'Some system description', 
	:qos_group => 'GroupB', :owner_id => 1
sys.save
puts 'added ' << sys.name

when "production"
#Default User
puts 'SETTING UP DEFAULT USER LOGIN'
@da = User.create! :name => 'Default Admin', :email => 'ttadmin@adobe.com', :admin => true, :verified => true, :password => 'password', :password_confirmation => 'password'
@da.save
puts 'New user created: ' << @da.name
user = User.create! :name => 'ExEmployeeMgr', :email => 'exempmgr@adobe.com', :verified => true, :password => 'password', :password_confirmation => 'A3kavazz'
user['manager_id'] = 1
user.save
puts 'New user created: ' << user.name

#Default Projects
proj = Project.create! :name => 'Maintenance/Tech Debt', :active => true, :owner => @da, :description => 'Bug fix, Tech Debt, Ops Improvements', :tribe => 'All', :category => 'HQA', :fixed_resource_budget => 15
proj.save
puts 'added maintenance project'
proj = Project.create! :name => 'Security-Compliance General', :active => true, :owner => @da, :description => 'Bug fixes and small sec/comp work items', :tribe => 'All', :category => 'Sec/Comp', :fixed_resource_budget => 10
proj.save
puts 'added security compliance project'
proj = Project.create! :name => 'Run the Business', :active => true, :owner => @da, :description => 'Operations and minor enhancements', :tribe => 'All',  :category => 'RTB', :fixed_resource_budget => 30
proj.save
puts 'added RTB Project'

#Default Systems
sys = TechSystem.create! :name => 'Tech Planning', :description => 'Used for assignmet of Tech Planning members', 
	:qos_group => 'Overhead', :owner => @da
sys.save
puts 'added ' << sys.name

sys = TechSystem.create! :name => 'Product Ops', :description => 'Used for assignmet of ops team members', 
	:qos_group => 'Offer Management', :owner => @da
sys.save
puts 'added ' << sys.name

#CoreSettings
set = Setting.create!  :stype => 0, :key => 'p_cust_1', :value => "", 
	:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with p_cust_1 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'p_cust_2', :value => "", 
	:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with p_cust_12 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'p_cust_3', :value => "", 
	:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with p_cust_3 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'cust_4', :value => "", 
	:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with cust_4 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'ts_cust_1', :value => "", 
	:description => 'Custom field for tech systems.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with ts_cust_1 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'ts_cust_2', :value => "", 
	:description => 'Custom field for tech systems.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with ts_cust_1 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'u_cust_1', :value => "", 
	:description => 'Custom field for users.  Admin can define visible name by setting displayname on this setting.  
		picklist values can be added to settings with ts_cust_1 as the key for those settings.'
set.save
puts 'added ' << set.key
set = Setting.create!  :stype => 0, :key => 'u_cust_2', :value => "", :description => 'Custom field for users.  Admin can define visible name by setting displayname on this setting.  picklist values can be added to settings with ts_cust_1 as the key for those settings.'
set.save
puts 'added ' << set.key

end










