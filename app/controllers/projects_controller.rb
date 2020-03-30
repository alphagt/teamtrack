class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show] 
	


  def dateTest
  
    #  USED FOR DEBUGGING DATE TO PERIOD CALCS - TEST ONLY
  	#*****************************
	puts "Testing 1 Jan 2019 ...."
	d = Date.new(2019,1,1)
	puts d.cweek	
  	puts view_context.period_from_date(d).to_s
  	
  	puts "Testing 2 July 2018 ...."
	d = Date.new(2018,7,2)
	puts d.cweek	
  	puts view_context.period_from_date(d).to_s
	
	puts "Testing 27 June 2019 ...."
	d = Date.new(2019,6,27)
	puts d.cweek	
  	puts view_context.period_from_date(d).to_s
	#*****************************
  end
  
  
  
  # GET /projects
  # GET /projects.json
  def index
	
	require 'gchart'
	
	#Full Project list used for aggregate statistics
	@allProjects = Project.by_category
	
	
	#Param Handling
	
	#Optional :org specifies a manager ID, default is current signed in user
	#     Special case for value set to 0 - will aggregate all projects in the system ('All')
	if params[:org].present?
		if params[:org].downcase == 'all'
			@mgr_id = 0
		else
			@mgr_id = params[:org].to_i 
		end
	else
		@mgr_id = current_user.id
	end
	puts "INDEX: MGR ID = "
	puts @mgr_id.to_s
	
	#Current FY Data
	
	if params[:fy].present?
		@fy = params[:fy].to_i
	else
		@fy = view_context.current_period().to_i
	end
	puts "Projects for FY: "
	puts @fy
	
	#Reset mgr_id to 0 if FY is not current FY to include all active and closed projects in view
	if @fy != view_context.current_fy() 
		@mgr_id = 0
		@scopeall = true
		#SET MGR TO ZERO DUE TO PREVIOUS FY, for anything other than current FY always show data unfiltered
	end
	
	#Optional :setq specifies a specific quarter number, defaul it current quarter
	if params[:setq].present?
		@setq = params[:setq].to_i
	else
		@setq = view_context.current_quarter()
	end
	puts @setq
	
	if @mgr_id != 0 && User.find(@mgr_id).orgowner
		@include_indirect = true
	else
		@include_indirect = false
	end
	
	#Optional :scope ('all' - Active and Closed projects, 'active' - active projects only [default]
	#     Sets the @projects variable for use in generating list of in scope projects for the view
	if (!params[:scope].present? && !@scopeall) || params[:scope] == 'active' 
		if @mgr_id == 0 || (current_user.isstatususer? && @mgr_id == current_user.id)  #called with no org selected by status user
			uList = []
			@projects = @allProjects.active
		else
			uList = view_context.all_subs_by_id(@mgr_id, @include_indirect)
			@projects = Project.active.for_users(uList).by_category
		end
	else
		@scopeall = true	
		if params[:scope] == 'all' || @fy != view_context.current_fy()
			if @mgr_id == 0 || (current_user.isstatususer? && @mgr_id == current_user.id)
				uList = []
				@projects = @allProjects
			else
				uList = view_context.all_subs_by_id(@mgr_id, @include_indirect)
				@projects = Project.for_users(uList).by_category
			end	
		end
	end

	if params[:showvals] == '1'
		@showVals = true
	else
		@showVals = false
	end
	
	if params[:statsview] == '1' || current_user.isstatususer? || current_user.admin?
		@statsView = true
	else
		@statsView = false
	end
	
	if uList.count == 0  then
		uList = User.all.pluck(:ID)
	end
	
#	#################################	
#	#Calculate and group fixed effort totals for chart
	
	@cfdata = Assignment.includes(:project).where('projects.category != ? AND set_period_id BETWEEN ? and ? AND projects.id IN (?) AND assignments.user_id IN (?)', 
		'Overhead', @fy.to_s, (@fy + 1).to_s, @allProjects.pluck(:id), uList).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'YTD Effort by Cat'
	puts @cfdata.to_s


	combinedytd = calc_chart_data(@cfdata)
	##### Finalize var to support chart creation ######
	@clabels_ytd = []
	@cvals_ytd = combinedytd.values
	puts "YTD Total"
	ytd_total = @cvals_ytd.sum
	puts ytd_total
	combinedytd.map do |key, val|
		@clabels_ytd << view_context.display_name_for("category",key).truncate(11) + "-" + (val.to_f/ytd_total * 100).round().to_s + "%"
	end	
	puts @clabels_ytd.to_s
	
		
	#Current Quarter Data
	case @setq #determin start end week number for each quarter
	when 1
		@eWeek = view_context.period_from_parts(@fy,13)
		@sWeek = @fy.to_s
# 		puts 'max week for period'
# 		puts @eWeek
	when 2
		@eWeek = view_context.period_from_parts(@fy,25)
		@sWeek = view_context.period_from_parts(@fy,12)
		puts 'start week for period'
		puts @sWeek.to_s
	when 3
		@eWeek = view_context.period_from_parts(@fy,37)
		@sWeek = view_context.period_from_parts(@fy,24)
		puts 'start week for period'
		puts @sWeek.to_s
	when 4
		@eWeek = view_context.period_from_parts(@fy,53)
		@sWeek = view_context.period_from_parts(@fy,36)
		puts 'start week for period'
		puts @sWeek.to_s
	end
		puts 'max week for current quarter'
		puts @eWeek

	#Select assignments for the quarter  date range that are not 'Overhead' grouped by category to display in pie chart
	@cfdata_qtd = Assignment.includes(:project).where("projects.category != ? AND set_period_id BETWEEN ? AND ? AND projects.id IN (?)", 
			'Overhead', @sWeek.to_s, @eWeek.to_s, @projects.pluck(:id)).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}

	puts 'Current Quarter Effort by Cat'
	puts @cfdata_qtd.to_s
	
	combinedqtd = calc_chart_data(@cfdata_qtd)
	

	##### Finalize var to support chart creation ######
		@clabels_qtd = []
		@cvals_qtd = combinedqtd.values
		puts "QTD Total"
		qtd_total = @cvals_qtd.sum
		puts qtd_total
		combinedqtd.map do |key, val|
			@clabels_qtd << view_context.display_name_for(Setting.for_key("p_cust_1")[0].value,key).truncate(11) + "-" + (val.to_f/qtd_total * 100).round().to_s + "%"
		end	
		puts @clabels_qtd.to_s
	
	
	#Calculate and group RTM and Stakeholder summary data for charts
	if @statsView then
		puts "in StatsView block"
		
		#Priority Chart Data (NOTE:  May want to cache this on a weekly basis)
		cweek = view_context.current_week
		puts "Current Week is"
		puts cweek
		#get grouped effort for assignments bounded by projects and users relevant to the viewing manager
		@ctpdata = Assignment.fte_only.includes(:project).where('projects.category != ? AND projects.keyproj = false AND 
			set_period_id BETWEEN ? and ? AND projects.id IN (?) AND assignments.user_id IN (?)', 
			'Overhead', @fy.to_s, (@fy + 1).to_s, @projects.pluck(:id), uList).group(['projects.initiative_id','projects.ctpriority']).references(:project).sum(:effort).map do |a|
		
			pri_custname = Setting.for_key("p_cust_4").pluck(:value)
			pri_custname.freeze
			pri_setting = Setting.for_key(pri_custname).where("value = ?",a[0][1].to_s)
			if pri_setting.count > 0 then
				pri_display = Setting.for_key(pri_custname).where("value = ?",a[0][1].to_s).first.displayname.truncate(11)
			else
				pri_display = a[0][1].to_s.truncate(11)
			end
			puts "##### DISPLAY NAME - "
			puts pri_display
			if !a[0][0].nil? then
				i = Initiative.find(a[0][0])
				
				if !i.tag.nil? then
					#cat = a[0][1].to_s + "-" + i.tag 
					cat = pri_display + "-" + i.tag
				else
					#cat = a[0][1].to_s + "-" + i.name 
					cat = pri_display + "-" + i.name.truncate(5)
				end
			else 
				#cat = a[0][1].to_s + "-" + "NA" 
				cat = pri_display + "-" + "NA" 
			end
			[cat,(a[1].to_f/cweek).round(2)]
		end
		#add quasi-priority to array for each keyproj 
		@keyprojdata = Assignment.fte_only.includes(:project).where('projects.category != ? AND projects.keyproj = true AND
			set_period_id BETWEEN ? and ? AND projects.id IN (?) AND assignments.user_id IN (?)', 
			'Overhead', @fy.to_s, (@fy + 1).to_s, @projects.pluck(:id), uList).group(['projects.initiative_id','projects.name']).references(:project).sum(:effort).map do |a|
			if !a[0][0].nil? then
				i = Initiative.find(a[0][0])
				if !i.tag.nil? then
					cat =i.tag + "-*" + a[0][1].truncate(11).to_s
				else
					cat = i.name.truncate(11) + "-*" + a[0][1].truncate(6).to_s
				end
			else 
				cat = "NA" + "-*" + a[0][1].truncate(11).to_s  
			end
			[cat,(a[1].to_f/cweek).round(2)]
		end	
		puts "PRIORITY KEY PROJECT DATA BLOCK:"
		puts @keyprojdata.to_s
		@ctpdata += @keyprojdata
		@ctpdata.sort!
		puts "PRIORITY SUMMARY DATA BLOCK:"
		puts @ctpdata.to_s
		#End CT Priority Chart section
		
#		#######################################
#		#####   RTM Effort Cals ############
		
		rtmeffort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
			@fy.to_s, (@fy + 1).to_s, 
			Project.for_users(uList).pluck(:id)).group('projects.rtm').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		puts "combined in hash"
		puts rtmeffort.to_s
		
		combinedrtm = calc_chart_data(rtmeffort,"p_cust_2")

			
		#### set the variables used in the view for charting
		puts "FINAL RTM HASH"
		puts combinedrtm.to_s
		
		alabs = []
		combinedrtm.map do |k,v|
			alabs << view_context.display_name_for(Setting.for_key("p_cust_2")[0].value,k).truncate(11) + "-" + v.round(2).to_s #TODO - change to percent of total?
		end
		@slabels = alabs
		@sVals = combinedrtm.values	
		

		#Stakeholder Calcs
		# Get sum of effort grouped by stakeholder values
		psheffort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
			@fy.to_s, (@fy + 1).to_s, 
			Project.for_users(uList).pluck(:id)).group('projects.psh').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		puts "STAKEHOLDER RAW DATA"
		puts psheffort.to_s
		combinedpsh = calc_chart_data(psheffort, 'p_cust_3')
		
		
		#### set the variables used in the view for charting
		puts "FINAL PSH HASH"
		puts combinedpsh.to_s
		
		alabs = []
		combinedpsh.map do |k,v|
			alabs << view_context.display_name_for(Setting.for_key("p_cust_3")[0].value,k).truncate(11) + "-" + v.round(2).to_s #TODO - change to percent of total?
		end
		@pshlabels = alabs
		@pshVals = combinedpsh.values	

	end
	
	puts "user scoped project list:"
	puts @projects.count
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  def import
  	require 'csv'
  	
  	#options = {:force_utf8, :strip_chars_from_headers => "s/([()])//g", :key_mapping => {:issue_key => :issue_key, :summary => :summary, :reporter => :owner}, :remove_unmapped_keys => true}
    
    tFile = params[:file]
    newproj = []
    cols = [:active, :name, :upl_number, :owner_id, :description]
	CSV.foreach(tFile.path, headers: true) do |r|
		puts r
		i = r.to_h
		puts i
		pid = i['Issue key'].split("-")[1].to_i || -1
		puts pid.to_s
		if Project.find_by_upl_number(pid).nil? then
			puts i.keys
			p = Hash.new()
			oUser = User.for_email(i['Owner'])
			if oUser.respond_to?(:id) then
				if oUser.ismanager
					oid = oUser.id
				else
					oid = oUser.manager_id || "1"
				end
			else
				oid = "1"
			end
			p[:active] = true
			p[:name] = i['Summary']
			p[:upl_number] = pid
			p[:owner_id] = oid
			p[:description] = i['Issue key']
			puts p.to_s
			newproj << p
		end
	end	
		
	sval = Project.import(cols,newproj, validate: false)
	puts newproj.to_s
		
	  respond_to do |format|
		  if sval
			format.html { redirect_to projects_path, notice: "Projects Imported" and return }
			format.json { render json: projects_path, status: :imported, location: @projects }
		  else
			format.html { render action: "index" }
			format.json { render json: @projects.errors, status: :unprocessable_entity }
		  end
	  end
  end
  
  # GET /projects/1
  # GET /projects/1.json
  def show
    require 'gchart'
    @project = Project.find(params[:id])

	#Prep Chart Data
	@clabels = []
	@cvalues = []
	@cdata = Assignment.recent(view_context.current_period - 0.10).where('set_period_id <= ? AND project_id = ?',  
		view_context.current_period, params[:id]).group(:set_period_id).sum(:effort).map{|a|[a[0],a[1].to_i]}
# 	puts 'Chart Data'
# 	puts @cdata
	@clabels = @cdata.to_h.keys.map{|e| "week " + view_context.week_from_period(e).to_s}
	@clabels.sort!
	@cvalues = @cdata.to_h.values
# 	puts 'Labels:'
# 	puts @clabels.to_s	
	#Data for systems pie chart
	@cdata = Assignment.where('set_period_id <= ? AND project_id = ? AND tech_sys_id > 0', 
		view_context.current_period, params[:id]).group(:tech_system).sum(:effort).map{|a|[a[0],a[1].to_i]}
	@slabels = @cdata.to_h.keys.map{|e| if !e.nil? then e.name else "TBD" end}
	@svalues = @cdata.to_h.values	
	
	#scope the assignment history per params
     if params[:history_scope] == 'all'
     	@ahistory = @project.assignments.by_org
     else
     	@ahistory = @project.assignments.recent(view_context.current_period - 0.06).by_org
#      	puts "TEST TEST"
#      	puts (view_context.current_period - 0.06).to_s
     end
     
	#End prep chart data
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new
	@ctplist = ctpLists()
	gon.ctplists = @ctplist
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @ctplist = ctpLists()
    puts @ctplist.to_s
    gon.ctplists = @ctplist
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
	@project.active = true
	
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
      	puts @project.errors.to_h.to_s
      	@error = @project.errors.to_h.to_s
        format.html { render action: "edit", alert: 'Update Failed: ' + @error }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /projects/1/archive
  def archive
  	@project = Project.find(params[:id])
  	@project.active = false
  	@project.fixed_resource_budget = 0
  	respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "archive" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  #utility to build array of possible ctp picklists for all active themes
  def ctpLists
  	puts "IN CTP UTIL"
  	out = []
  	lasti = -1
  	Initiative.all.each do |i| 
  		puts "processing an init: " + i.id.to_s
  		
  		while((i.id - lasti) > 1) do
  			#fill the gap in idexes in the array
  			out << [""]
  			lasti += 1
  		end
  		if i.subprilist.present? then
  			out << i.subprilist
  		else
  			out << [""]
  		end
  		lasti += 1
  	end
  	puts out.length
  	out
  end
  
private
	# Use callbacks to share common setup or constraints between actions.
	def set_project
	  @project = Project.find(params[:id])
	end

	# Only allow a trusted parameter "white list" through.
	def project_params
# 		attr_accessible :owner, :initiative, :active, :description, :category, :name, :owner_id,
#   		:initiative_id, :fixed_resource_budget, :upl_number, :keyproj, :rtm, :psh, :tribe, :ctpriority

	  params.require(:project).permit(:owner, :initiative, :active, :description, :category, :name, :owner_id,
  		:initiative_id, :fixed_resource_budget, :upl_number, :keyproj, :rtm, :psh, :tribe, :ctpriority)
	end
end
