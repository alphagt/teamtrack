class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show] 
	
  # GET /projects
  # GET /projects.json
  def index
	
	require 'gchart'
	@allProjects = Project.by_category
	if params[:scope] == 'all'
		@projects = @allProjects
	else
		if params[:scope] == 'active'
			@projects = Project.active.by_category
		else
			@projects = Project.active.for_users(view_context.all_subs_by_id(current_user)).by_category
		end
	end
	if params[:showvals] == '1'
		@showVals = true
	else
		@showVals = false
	end
	
	#Calculate and group fixed effort totals for chart
	#Current FY Data
	@fy = view_context.current_period().to_i
	@cfdata = Assignment.includes(:project).where('projects.category != ? AND set_period_id > ? AND projects.id IN (?)', 
		'Overhead', @fy.to_s, @allProjects.pluck(:id)).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'YTD Effort by Cat'
	puts @cfdata.to_s
	puts Assignment.includes(:project).where('projects.category != ? AND set_period_id > ? AND projects.id IN (?)', 
		'Overhead', @fy.to_s, @allProjects.pluck(:id)).to_sql
	@clabels_ytd = @cfdata.to_h.keys
	@clabels_ytd.sort!
	@cvals_ytd = @cfdata.to_h.values

	#Current Quarter Data
	case view_context.current_quarter() #determin start end week number for each quarter
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
	puts Assignment.includes(:project).where("projects.category != ? AND set_period_id BETWEEN ? AND ? AND projects.id IN (?)", 
			'Overhead', @sWeek.to_s, @eWeek.to_s, @projects.pluck(:id)).to_sql
	@clabels_qtd = @cfdata_qtd.to_h.keys
	@clabels_qtd.sort!
	@cvals_qtd = @cfdata_qtd.to_h.values

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
