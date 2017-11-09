case Rails.env


when "development"
#Default User
puts 'SETTING UP DEFAULT USER LOGIN'
@suser = User.create! :name => 'Ken Toole', :email => 'ktoole@adobe.com', :admin => true, :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
@suser.save
puts 'New user created: ' << @suser.name
proj = Project.create! :name => 'Maintenance/Tech Debt', :active => true, :owner => @suser, :description => 'Bug fix, Tech Debt, Ops Improvements', :tribe => 'All', :category => 'HQA', :fixed_resource_budget => 15
proj.save
puts 'added maintenance project'
proj = Project.create! :name => 'Security-Compliance Maintenance', :active => true, :owner => @suser, :description => 'Bug fixes and small sec/comp work items', :tribe => 'All', :category => 'Sec/Comp', :fixed_resource_budget => 10
proj.save
puts 'added security compliance project'
proj = Project.create! :name => 'Run the Business', :active => true, :owner => @suser, :description => 'RTB work via CTIR Process', :tribe => 'All',  :category => 'RTB', :fixed_resource_budget => 30
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
@ken = User.create! :name => 'Ken Toole', :email => 'ktoole@adobe.com', :admin => true, :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
@ken.save
puts 'New user created: ' << @ken.name
user = User.create! :name => 'ExEmployeeMgr', :email => 'test2@adobe.com', :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
user['manager_id'] = 1
user.save
puts 'New user created: ' << user.name
user = User.create! :name => 'Jen Sutherland', :email => 'jsutherla@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
user['manager_id'] = 1
user.impersonates = @ken
user.save
puts 'New user created: ' << user.name
user = User.create! :name => 'Bridie Saccocio', :email => 'bsaccoci@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
user['manager_id'] = 1
user.impersonates = @ken
user.save
puts 'New user created: ' << user.name

#Default Projects
proj = Project.create! :name => 'Maintenance/Tech Debt', :active => true, :owner => @ken, :description => 'Bug fix, Tech Debt, Ops Improvements', :tribe => 'All', :category => 'HQA', :fixed_resource_budget => 15
proj.save
puts 'added maintenance project'
proj = Project.create! :name => 'Security-Compliance General', :active => true, :owner => @ken, :description => 'Bug fixes and small sec/comp work items', :tribe => 'All', :category => 'Sec/Comp', :fixed_resource_budget => 10
proj.save
puts 'added security compliance project'
proj = Project.create! :name => 'Run the Business', :active => true, :owner => @ken, :description => 'RTB work via CTIR Process', :tribe => 'All',  :category => 'RTB', :fixed_resource_budget => 30
proj.save
puts 'added RTB Project'

#Valdez and Systems
@valdez = User.create! :name => "Don Valdez", :email => 'dvaldez@adobe.com', :admin => false, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@valdez.manager = @ken
@valdez.save
puts 'New user created: ' << @valdez.name
user = User.create! :name => 'Josh King', :email => 'jking@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
user.manager = @valdez
user.save
puts 'New user created: ' << user.name
sys = TechSystem.create! :name => 'Tech Planning', :description => 'Used for assignmet of Tech Planning members', 
	:qos_group => 'Overhead', :owner => @valdez
sys.save
puts 'added ' << sys.name

#Ewing and Systems
@ewing = User.create! :name => "Michael Ewing", :email => 'mewing@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@ewing.manager = @ken
@ewing.save
puts 'New user created: ' << @ewing.name
user = User.create! :name => 'Koji Yoshida', :email => 'kyoshida@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
user.manager = @ewing
user.save
puts 'New user created: ' << user.name
sys = TechSystem.create! :name => 'Product Ops', :description => 'Used for assignmet of ops team members', 
	:qos_group => 'Offer Management', :owner => @ewing
sys.save
puts 'added ' << sys.name

#O'Lenskie and Systems
@adrian = User.create! :name => "Adrian O'Lenskie", :email => 'aolenski@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@adrian.manager = @ken
@adrian.save
puts 'New user created: ' << @adrian.name

sys = TechSystem.create! :name => 'JILv2', :description => 'Primary Business Orchestration Layer', 
	:qos_group => 'Business Platform', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'UM SDK', :description => 'Public API for Ent. User Mgmt.', 
	:qos_group => 'Business Platform', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Hoolihan', :description => 'Reliable Messaging Infrastructure', 
	:qos_group => 'Business Platform', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'ERS', :description => 'Endpoint Resolution Service', 
	:qos_group => 'Business Platform', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'SDS', :description => 'Offer Data Mangagement Service', 
	:qos_group => 'Offer Management', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Mechandizing Service', :description => 'Localized Product Marketing Content Service', 
	:qos_group => 'Offer Management', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'SSOCM', :description => 'Self-Service Offer Creation UI', 
	:qos_group => 'Offer Management', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Products Service', :description => 'Legacy Pre-Purchase Service', 
	:qos_group => 'Commerce', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Subscription Policy Services', :description => 'Various policy definition services (CPS, TPS, etc)', 
	:qos_group => 'Offer Management', :owner => @adrian
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Available Offers Service', :description => 'Offer catalog provider', 
	:qos_group => 'Commerce', :owner => @adrian
sys.save
puts 'added ' << sys.name
#Olenskie Managers
@suser = User.create! :name => "Nick Goodall", :email => 'goodall@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @adrian
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "David Thomson", :email => 'dthomson@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @adrian
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Guo Wei", :email => 'weiguo@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @adrian
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Harinder Sandhu", :email => 'harinder@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @adrian
@suser.save
puts 'New user created: ' << @suser.name


#Koratkar and Systems
@suser = User.create! :name => "Ankush Koratkar", :email => 'koratkar@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.save
puts 'New user created: ' << @suser.name
sys = TechSystem.create! :name => 'Unified Checkout', :description => 'Adobe common checkout UI', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'CCM UI', :description => 'Legacy CC checkout UI', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Edit Billing', :description => 'Adobe common billing mgmt UI', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Anywhere Checkout', :description => 'Legacy checkout UI', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Orders v3', :description => 'Adobe Order Capture Service', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'SESI', :description => 'Adobe Integration hub for order fulfillment and invoicing', 
	:qos_group => 'Business Platform', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Order Processing Service', :description => 'Adobe backend order processing service', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Token Broker Service', :description => 'Adobe payment token handling service', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'PTS', :description => 'Payment Tokens Service', 
	:qos_group => 'Commerce', :owner => @suser
sys.save
puts 'added ' << sys.name
#Managers
@steve = User.create! :name => "Steve Breinberg", :email => 'sbreinbe@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@steve.manager = @suser
@steve.save
puts 'New user created: ' << @steve.name
@vijays = User.create! :name => "Vijay Shah", :email => 'vshah@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@vijays.manager = @suser
@vijays.save
puts 'New user created: ' << @vijays.name
@pbs = User.create! :name => "Pankaj Shah", :email => 'pbs@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@pbs.manager = @suser
@pbs.save
puts 'New user created: ' << @pbs.name
@suser = User.create! :name => "Elena Lubivy", :email => 'elubivy@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @steve
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Manu Gopinath", :email => 'mgopinat@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @vijays
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Gaurav Jain", :email => 'gauravj@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @steve
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Rupesh Kumar", :email => 'rukumar@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @vijays
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Sanjeev Kumar", :email => 'sanjkuma@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @vijays
@suser.save
puts 'New user created: ' << @suser.name


#Bawa and Systems
@bawa = User.create! :name => "Sumeet Bawa", :email => 'sbawa@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@bawa.manager = @ken
@bawa.save
puts 'New user created: ' << @bawa.name


sys = TechSystem.create! :name => 'AAC', :description => 'Adobe Admin Console - Team', 
	:qos_group => 'Admin Experiences', :owner => @bawa
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Ent-D', :description => 'Enterprise Dashboard- Legacy', 
	:qos_group => 'Admin Experiences', :owner => @bawa
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'OAC', :description => 'One Adobe Console', 
	:qos_group => 'Admin Experiences', :owner => @bawa
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Reseller Console', :description => 'Reseller Admin Console', 
	:qos_group => 'Admin Experiences', :owner => @bawa
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Mercury Invite Service', :description => 'Common inivite tracking and management', 
	:qos_group => 'Busines Platform', :owner => @bawa
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'Device Licensing Snap-In', :description => 'Device License Mgmt UI', 
	:qos_group => 'Admin Experiences', :owner => @bawa
sys.save
puts 'added ' << sys.name
sys = TechSystem.create! :name => 'AAUI', :description => 'Adobe internal admin tool for contract provisioning', 
	:qos_group => 'Business Platform', :owner => @bawa
sys.save
puts 'added ' << sys.name

#managers
@suser = User.create! :name => "James Boag", :email => 'boag@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @bawa
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Demian Godon", :email => 'dgodon@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @bawa
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Nathan Hoover", :email => 'nahoover@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @bawa
@suser.save
puts 'New user created: ' << @suser.name

#Chatterjee and Systems
@arijit = User.create! :name => "Arijit Chatterjee", :email => 'arijit@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@arijit.manager = @ken
@arijit.save
puts 'New user created: ' << @arijit.name
sys = TechSystem.create! :name => 'LDS', :description => 'License Delegation Service', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'LM Stack', :description => 'Desktop Licensing Service', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'SNS', :description => 'Legacy Serial Number Server', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'SNS-Next', :description => 'Replacement Technology for SNS', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'TACT', :description => 'Trial Activation Server/OFT Services', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'DBCS Service', :description => 'Device Based Licensing Service', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'SNS-Next', :description => 'Replacement Technology for SNS', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'Device Mgmt Service', :description => 'Device management service for users', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'Desktop Lic Client', :description => 'Client Libraries for DT Licensing', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save
sys = TechSystem.create! :name => 'Go-Cart', :description => 'Piracy Remediation Service', 
	:qos_group => 'Entitlement', :owner => @arijit
sys.save

#Managers
@suser = User.create! :name => "Sravana K Dindukurti", :email => 'sravanak@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @arijit
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Brijesh Nair", :email => 'bnair@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @arijit
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Dhiraj Sadhwani", :email => 'sadhwani@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @arijit
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Srikanth V", :email => 'srv@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @arijit
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Vikalp Gupta", :email => 'vikgupta@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @arijit
@suser.save
puts 'New user created: ' << @suser.name

#Vijay G and Systems
@vijayg = User.create! :name => "Vijay Ghaskadvi", :email => 'vghaskad@adobe.com', :admin => true, :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@vijayg.manager = @ken
@vijayg.save
puts 'New user created: ' << @vijayg.name
sys = TechSystem.create! :name => 'JEM', :description => 'Subscription Managment Service', 
	:qos_group => 'Subscriptions Infrastructure', :owner => @vijayg
sys.save
sys = TechSystem.create! :name => 'JEAP', :description => 'Internal admin service and portal for JEM', 
	:qos_group => 'Subscriptions Infrastructure', :owner => @vijayg
sys.save
sys = TechSystem.create! :name => 'Contract Cart', :description => 'Order capture and organization service', 
	:qos_group => 'Commerce', :owner => @vijayg
sys.save
sys = TechSystem.create! :name => 'WCD', :description => 'Legacy user registration and misc service', 
	:qos_group => 'Subscriptions Infrastructure', :owner => @vijayg
sys.save
sys = TechSystem.create! :name => 'Subs Life-Cycle Service', :description => 'Subscription life-cycle management Service', 
	:qos_group => 'Subscriptions Infrastructure', :owner => @vijayg
sys.save
sys = TechSystem.create! :name => 'Renewal Service', :description => 'Renewal Orchestration Service', 
	:qos_group => 'Subscriptions Infrastructure', :owner => @vijayg
sys.save

#Managers
@suser = User.create! :name => "Mayank Kumar", :email => 'kumarm@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @vijayg
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Wei Cheng", :email => 'wcheng@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @vijayg
@suser.save
puts 'New user created: ' << @suser.name
@suser = User.create! :name => "Prachi Sonalkar", :email => 'psonalka@adobe.com', :verified => true, :password => 'abc123', :password_confirmation => 'abc123'
@suser.manager = @vijayg
@suser.save
puts 'New user created: ' << @suser.name

end










