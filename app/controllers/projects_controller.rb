class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show] 
	
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
		puts "SET MGR TO ZERO DUE TO PREVIOUS FY"
	end
	
	#Optional :setq specifies a specific quarter number, defaul it current quarter
	if params[:setq].present?
		@setq = params[:setq].to_i
	else
		@setq = view_context.current_quarter()
	end
	puts @setq
	
	#Optional :scope ('all' - Active and Closed projects, 'active' - active projects only [default]
	#     Sets the @projects variable for use in generating list of in scope projects for the view
	if (!params[:scope].present? && !@scopeall) || params[:scope] == 'active' 
		if @mgr_id == 0 || current_user.isstatususer?
			uList = []
			@projects = @allProjects.active
		else
			uList = view_context.all_subs_by_id(@mgr_id)
			@projects = Project.active.for_users(view_context.all_subs_by_id(@mgr_id)).by_category
		end
	else
		@scopeall = true	
		if params[:scope] == 'all' || @fy != view_context.current_fy()
			if @mgr_id == 0 || current_user.isstatususer?
				uList = []
				@projects = @allProjects
			else
				uList = view_context.all_subs_by_id(@mgr_id)
				@projects = Project.for_users(view_context.all_subs_by_id(@mgr_id)).by_category
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
	
	
	#Calculate and group fixed effort totals for chart
	
	@cfdata = Assignment.includes(:project).where('projects.category != ? AND set_period_id BETWEEN ? and ? AND projects.id IN (?)', 
		'Overhead', @fy.to_s, (@fy + 1).to_s, @allProjects.pluck(:id)).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'YTD Effort by Cat'
	puts @cfdata.to_s
	#puts Assignment.includes(:project).where('projects.category != ? AND set_period_id > ? AND projects.id IN (?)', 'Overhead', @fy.to_s, @projects.pluck(:id)).to_sql
	@clabels_ytd = []
	@cvals_ytd = @cfdata.to_h.values
	puts "YTD Total"
	ytd_total = @cvals_ytd.sum
	puts ytd_total
	@cfdata.to_h.each do |key, val|
		@clabels_ytd << key + "-" + (val.to_f/ytd_total * 100).round().to_s + "%"
	end	
	puts @clabels_ytd.to_s
	@clabels_ytd.sort!

	
	
	if uList.count == 0  then
		uList = User.all.pluck(:ID)
	end
	
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
	#puts Assignment.includes(:project).where("projects.category != ? AND set_period_id BETWEEN ? AND ? AND projects.id IN (?)", 'Overhead', @sWeek.to_s, @eWeek.to_s, @projects.pluck(:id)).to_sql
	@clabels_qtd = []
	@cvals_qtd = @cfdata_qtd.to_h.values
	puts "QTD Total"
	qtd_total = @cvals_qtd.sum
	puts qtd_total
	@cfdata_qtd.to_h.each do |key, val|
		@clabels_qtd << key + "-" + (val.to_f/qtd_total * 100).round().to_s + "%"
	end	
	puts @clabels_qtd.to_s
	@clabels_qtd.sort!
	
	#Calculate and group RTM and Stakeholder summary data for charts
	if @statsView then
		puts "in StatsView block"
		#RTM Calcs
		# all_effort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
# 			@fy.to_s, (@fy + 1).to_s, Project.for_rtm("All").for_users(uList).pluck(:id)).sum(:effort)
# 		puts all_effort.to_s
# 		b2b_effort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
# 			@fy.to_s, (@fy + 1).to_s, Project.for_rtm("B2B").for_users(uList).pluck(:id)).sum(:effort)
# 		puts b2b_effort.to_s
# 		ind_effort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
# 			@fy.to_s, (@fy + 1).to_s, Project.for_rtm("Individual").for_users(uList).pluck(:id)).sum(:effort)
# 		puts ind_effort
# 		mid_effort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
# 			@fy.to_s, (@fy + 1).to_s, Project.for_rtm("Mid-Market").for_users(uList).pluck(:id)).sum(:effort)
# 		puts mid_effort
# 		ent_effort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
# 			@fy.to_s, (@fy + 1).to_s, Project.for_rtm("Enterprise").for_users(uList).pluck(:id)).sum(:effort)
# 		puts ent_effort
		
		rtmeffort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
			@fy.to_s, (@fy + 1).to_s, 
			Project.for_users(uList).pluck(:id)).group('projects.rtm').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		puts "combined in hash"
		puts rtmeffort.to_s
		combinedrtm = rtmeffort.to_h
		
		if combinedrtm.key?("All") then all_effort = combinedrtm["All"].to_d else all_effort = 0 end
		if combinedrtm.key?("B2B") then b2b_effort = combinedrtm["B2B"].to_d else b2b_effort = 0 end
		if combinedrtm.key?("Individual") then ind_effort = combinedrtm["Individual"].to_d else ind_effort = 0 end
		if combinedrtm.key?("Mid-Market") then mid_effort = combinedrtm["Mid-Market"].to_d else mid_effort = 0 end
		if combinedrtm.key?("Enterprise") then ent_effort = combinedrtm["Enterprise"].to_d else ent_effort = 0 end
		
		ind_effort += all_effort/3
		mid_effort = mid_effort + (all_effort/3) + (b2b_effort/2)
		ent_effort = ent_effort + (all_effort/3) + (b2b_effort/2)
		#sum_effort = ind_effort + mid_effort + ent_effort
		sum_effort = combinedrtm.values.sum
		if sum_effort > 0
			@slabels = ["Individual-" + (ind_effort/sum_effort * 100).round().to_s + "%", 
					"Mid-Market-" + (mid_effort/sum_effort * 100).round().to_s + "%", 
					"Enterprise-" + (ent_effort/sum_effort * 100).round().to_s + "%"]
		else
			@slabels = ["Individual-", 
					"Mid-Market-", 
					"Enterprise-"]
		end
		@sVals = [ind_effort, mid_effort, ent_effort]
		
		#Stakeholder Calcs
		# Get sum of effort grouped by stakeholder values
		psheffort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
			@fy.to_s, (@fy + 1).to_s, 
			Project.for_users(uList).pluck(:id)).group('projects.psh').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		puts "combined in hash"
		puts psheffort.to_s
		combinedpsh = psheffort.to_h.except("NA")
		
		# determine portion of effort tagged as 'Adobe' that came from projects in the Individual RTM
		ind_psh_effort = Assignment.includes(:project).where('rtm = ? AND set_period_id BETWEEN ? and ? AND projects.id IN (?)', "Individual",
 			@fy.to_s, (@fy + 1).to_s, Project.for_psh("Adobe").for_users(uList).pluck(:id)).sum(:effort)
		
		# Set adobe_effort to portion applicable to all stakeholders but subtracting out the Individual RTM portion
		if combinedpsh.key?("Adobe") then adobe_effort = (combinedpsh["Adobe"].to_d - ind_psh_effort) else adobe_effort = 0 end
		if combinedpsh.key?("SG&A") then sga_effort = combinedpsh["SG&A"].to_d else sga_effort = 0 end
		if combinedpsh.key?("DME") then dme_effort = combinedpsh["DME"].to_d else dme_effort = 0 end
		if combinedpsh.key?("DMA") then dma_effort = combinedpsh["DMA"].to_d else dma_effort = 0 end
		if combinedpsh.key?("DC") then dc_effort = combinedpsh["DC"].to_d else dc_effort = 0 end
		
		totalpsh_effort = combinedpsh.values.sum
		puts totalpsh_effort
		
		sga_effort += (adobe_effort * 0.1)
		dme_effort += (adobe_effort * 0.5) + (ind_psh_effort * 0.7) # Add 50% of non-individual Adobe and 70% indivdiual adobe effort
		dma_effort += (adobe_effort * 0.3) 
		dc_effort += (adobe_effort * 0.1) + (ind_psh_effort * 0.3)  # Add 10% non-individual Adobe and 30% indvidual Adobe effort
		
		# Format labels with % values appended since gchart gem doesn't support percent on label feature
		if totalpsh_effort > 0
			@pshlabels = ["SG&A-" + (sga_effort/totalpsh_effort * 100).round().to_s + "%",
					  "DME-" + (dme_effort/totalpsh_effort * 100).round().to_s + "%",
					  "DMA-" + (dma_effort/totalpsh_effort * 100).round().to_s + "%",
					  "DC-" + (dc_effort/totalpsh_effort * 100).round().to_s + "%"]
		else
			@pshlabels = ["SG&A-",
					  "DME-",
					  "DMA-",
					  "DC-"]
		end
		@pshVals = [sga_effort, dme_effort, dma_effort, dc_effort]
		
	end
	
	puts "user scoped project list:"
	puts @projects.count
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
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
     	@ahistory = @project.assignments.order("set_period_id DESC")
     else
     	@ahistory = @project.assignments.recent(view_context.current_period - 0.06)
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
	
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(params[:project])
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
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
end
