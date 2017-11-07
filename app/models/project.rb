class Project < ActiveRecord::Base
  belongs_to :owner, :class_name => "User"
  belongs_to :initiative
  has_many :assignments
  has_many :users, -> { order "users.name" }, :through => :assignments
  attr_accessible :owner, :initiative, :active, :description, :category, :name, :owner_id,
  	:initiative_id, :fixed_resource_budget, :upl_number, :keyproj, :rtm

  validates :fixed_resource_budget, :presence => true
  
   
	scope :for_users, -> (uList){joins(:users).where('assignments.user_id IN (?)', uList).distinct}
	scope :active, -> {where('active = true')}
	scope :keyproj, -> {where('keyproj = true')}
	scope :by_name, -> {order('projects.name')}
	scope :by_category, -> {order('projects.category','projects.name')}
	scope :by_initiative, -> {order('projects.initiative', 'projects.name')}
	scope :for_initiative, -> (iId){where('initiative_id = ?', iId).order('projects.name')}
	scope :by_rtm, -> {order('projects.rtm', 'projects.name')}
	scope :for_rtm, -> (rStr){where('rtm = ?', rStr).order('projects.name')}
	
	def under_budget(pId)
		tEffort = 0
		assignments.where(:set_period_id => pId).each do |a|
			tEffort += a.effort
		end
		fixed_resource_budget > tEffort
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
				if fy = 0 then @fyear = @fyear + 1 end
				@cweek_number = (Date.today.cweek + 4) - 52
			else
				@cweek_number = Date.today.cweek + 4
			end
		end
		#puts 'CURRENT CWEEK Number: '
		#puts  @cweek_number
		#to fix - need to do a range query then sum effort instead of interating
		for iWeek in 1..@cweek_number
			@cP = @fyear.to_f + (iWeek.to_f / 100)
			assignments.where(:set_period_id => @cP.round(2)).each do |asn|
				puts asn.effort.to_s
				@ytd += asn.effort
			end
		end
		@ytd.to_d.round(2)
	end
end
