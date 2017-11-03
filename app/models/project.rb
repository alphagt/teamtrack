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
	
	def ytd_allocation
		@ytd = 0
		@cperiod = 0.0
		#calc current period code
		@cweek_number = 0.0
		@fyear = Date.today.year 
		if Date.today.mon == 12 then
			@fyear = @fyear + 1
			@cfy_offset = 4 #SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
			@cweek_number = Date.today.cweek + @cfy_offset - 52
		else
			@cfy_offset = 4 #SetPeriod.where(:fiscal_year => @fyear).first!.cweek_offset
			@cweek_number = Date.today.cweek + @cfy_offset
		end
		#puts 'CURRENT CWEEK Number: '
		#puts  @cweek_number
		@cperiod = @fyear + @cweek_number.fdiv(100).round(3)
		#end cperiod
		@pFy = @cperiod.to_i
		@fWeek = ((@cperiod - @pFy) * 100).round
		#puts "fweek = " + @fWeek.to_s
		for iWeek in 1..@fWeek
			@cP = @pFy.to_f + (iWeek.to_f / 100)
			assignments.where(:set_period_id => @cP.round(2)).each do |asn|
				puts asn.effort.to_s
				@ytd += asn.effort
			end
		end
		@ytd.to_d.round(2)
	end
end
