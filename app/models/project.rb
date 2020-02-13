class Project < ApplicationRecord
  belongs_to :owner, :class_name => "User"
  belongs_to :initiative
  has_many :assignments
  has_many :users, -> { order "users.name" }, :through => :assignments
  attr_accessible :owner, :initiative, :active, :description, :category, :name, :owner_id,
  	:initiative_id, :fixed_resource_budget, :upl_number, :keyproj, :rtm, :psh, :tribe, :ctpriority

  validates :fixed_resource_budget, :presence => true
  #Disabled initiative-priority correlation check for now - need to hanlde new ctp better
  #validate :ctpriority_supported_by_initiative, if: 'ctpriority.present?'
  
   
	scope :for_users, -> (uList){joins(:users).where('assignments.user_id IN (?)', uList).distinct}
	scope :for_owners, -> (uList){where('owner_id IN (?)', uList).distinct}
	scope :for_year, -> (fy){joins(:users).where('assignments.set_period_id between ? and ?', fy, fy + 1).distinct}
	scope :active, -> {where('active = true')}
	scope :keyproj, -> {where('keyproj = true')}
	scope :by_name, -> {order('projects.name')}
	scope :by_category, -> {order('projects.category','projects.name')}
	scope :by_initiative, -> {order('projects.initiative', 'projects.name')}
	scope :for_initiative, -> (iId){where('initiative_id = ?', iId).order('projects.name')}
	scope :by_rtm, -> {order('projects.rtm', 'projects.name')}
	scope :for_rtm, -> (rStr){where('rtm = ?', rStr).order('projects.name')}
	scope :for_psh, -> (shStr){where('psh = ?', shStr).order('projects.name')}

	def ctpriority_supported_by_initiative
		if initiative_id && initiative_id != 0 then
			puts "CHECKING INITIATIVE - CTP CORRELATION"
			i = Initiative.find(initiative_id)
			if !i.subprilist.include?(ctpriority) then
				errors.add(:ctpriority, "Sub Priority not supported for selected Initiative")
			end
		end
	end
	def under_budget(pId)
		tEffort = 0
		assignments.where(:set_period_id => pId).each do |a|
			tEffort += a.effort
		end
		if !fixed_resource_budget then
			true
		else
			fixed_resource_budget > tEffort
		end
	end
	
	def ytd_allocation(fy = 0, maxWeek = 0)
		@ytd = 0
		if fy > 0 then
			@fyear = fy
		else
			@fyear = Date.today.year
		end
		#calc current period code
		@cweek_number = 0.0
		if maxWeek > 0 then
			@cweek_number = maxWeek.to_d
		else
			if Date.today.mon == 12 then
				if fy == 0 then @fyear = @fyear + 1 end
				@cweek_number = (Date.today.cweek + 4) - 52
			else
				@cweek_number = Date.today.cweek + 4
			end
		end
		#puts 'CURRENT CWEEK Number: '
		#puts  @cweek_number
		#to fix - need to do a range query then sum effort instead of interating
		
		@ytd = assignments.where("set_period_id > ? and set_period_id < ?", 
			@fyear.to_f, @fyear.to_f + (@cweek_number+1).to_f/100).sum(:effort)
		puts "SUM RESULT:  ?", @ytd.to_s
		
		#Deprecated IMPL
		# 	for iWeek in 1..@cweek_number
	# 			@cP = @fyear.to_f + (iWeek.to_f / 100)
	# 			assignments.where(:set_period_id => @cP.round(2)).each do |asn|
	# 				puts asn.effort.to_s
	# 				@ytd += asn.effort
	# 			end
	# 		end
		#**********
		@ytd.to_d.round(2)
	end
end
