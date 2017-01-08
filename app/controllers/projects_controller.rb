class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show] 
	
  # GET /projects
  # GET /projects.json
  def index
	
	require 'gchart'
	
	if params[:scope] == 'all'
		@projects = Project.order("projects.category","projects.name")
	else
		@projects = Project.active.for_users(view_context.all_subs_by_id(current_user)).order("projects.category","projects.name")
	end
	
	#Calculate and group fixed effort totals for chart
	#Current FY Data
	@cfdata = Assignment.includes(:project).where('set_period_id > 2017 AND projects.id IN (?)', @projects.pluck(:id)).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'Effort by Cat'
	puts @cfdata.to_s
	@clabels_ytd = @cfdata.to_h.keys
	@clabels_ytd.sort!
	@cvals_ytd = @cfdata.to_h.values

	#Current Quarter Data
	@fy = view_context.current_period().to_i
	case view_context.current_quarter()
	when 1
		@eWeek = view_context.period_from_parts(@fy,13)
		puts 'max week for period'
		puts @eWeek
		#@cfdata = Assignment.includes(:project).where(@fy.to_s + '< set_period_id <' + @eWeek.to_s).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		@cfdata = Assignment.includes(:project).where('? < set_period_id < ? AND projects.id IN (?)', @fy.to_s, @eWeek.to_s, @projects.pluck(:id)).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	when 2
		@eWeek = view_context.period_from_parts(@fy,25)
		@sWeek = view_context.period_from_parts(@fy,12)
		puts 'max week for period'
		puts @eWeek
		@cfdata = Assignment.includes(:project).where(@sWeek.to_s + '< set_period_id <' + @eWeek.to_s).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	when 3
		@eWeek = view_context.period_from_parts(@fy,37)
		@sWeek = view_context.period_from_parts(@fy,24)
		puts 'max week for period'
		puts @eWeek
		@cfdata = Assignment.includes(:project).where(@sWeek.to_s + '< set_period_id <' + @eWeek.to_s).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}	
	when 4
		@eWeek = view_context.period_from_parts(@fy,53)
		@sWeek = view_context.period_from_parts(@fy,36)
		puts 'max week for period'
		puts @eWeek
		@cfdata = Assignment.includes(:project).where(@sWeek.to_s + '< set_period_id <' + @eWeek.to_s).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}	
	end
	puts 'Effort by Cat'
	puts @cfdata.to_s
	@clabels_qtd = @cfdata.to_h.keys
	@clabels_qtd.sort!
	@cvals_qtd = @cfdata.to_h.values

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
	@cdata = Assignment.where('set_period_id <= ? AND project_id = ?', 
		view_context.current_period, params[:id]).group(:set_period_id).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'Chart Data'
	puts @cdata
	@clabels = @cdata.to_h.keys.map{|e| "week " + view_context.week_from_period(e).to_s}
	@clabels.sort!
	@cvalues = @cdata.to_h.values
	puts 'Labels:'
	puts @clabels.to_s	
	#Data for systems pie chart
	@cdata = Assignment.where('set_period_id <= ? AND project_id = ? AND tech_sys_id > 0', 
		view_context.current_period, params[:id]).group(:tech_system).sum(:effort).map{|a|[a[0],a[1].to_i]}
	@slabels = @cdata.to_h.keys.map{|e| if !e.nil? then e.name else "TBD" end}
	@svalues = @cdata.to_h.values	
		
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
  	@project.category += "-Archived"
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
