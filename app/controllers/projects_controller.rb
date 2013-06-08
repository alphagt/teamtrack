class ProjectsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show] 
	
  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.order("category","name")
    @cdata = []
	require 'gchart'
	#Calculate and group fixed effort totals for chart
	@cfdata = Assignment.sum(:effort, :conditions => ["set_period_id = ?  AND is_fixed = ? AND projects.active = ? ", 
		view_context.current_period(),true,true],:include => :project, :group => 'projects.category', :order => 'projects.category')
	puts 'Fixed by Cat'
	puts @cfdata.to_s
    #Calculate and group Nitro effort totals for chart
    @cndata = Assignment.sum(:effort, :conditions => ["set_period_id = ?  AND is_fixed = ? AND projects.active = ? ", 
		view_context.current_period(),false,true],:include => :project, :group => 'projects.category', :order => 'projects.category')
	puts 'Nitro by Cat'
	puts @cndata.to_s
	@clabels = @cfdata.merge(@cndata).keys
	@clabels.sort!
	puts 'Labels Array'
	puts @clabels.to_s
	@tempfixed = []
	@clabels.map {|l|
		@tempfixed.push(@cfdata.fetch(l,0))}
	#puts @tempfixed.to_s
	@cdata.push(@tempfixed)
	@tempnitro = []
	@clabels.map {|l|
		@tempnitro.push(@cndata.fetch(l,0))}
	#puts @tempnitro.to_s
	@cdata.push(@tempnitro)
	puts 'Values Array'
	puts @cdata.to_s
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = Project.find(params[:id])

	#Prep Chart Data
	@clabels = []
	@cvalues = []
	@cdata = Assignment.sum(:effort, :conditions => ["project_id = ? AND set_period_id <= ?", @project.id, view_context.current_period()], :group => :set_period_id,
		:order => ["set_period_id DESC"]).first(12)
	puts 'Chart Data'
	puts @cdata.to_s
	@cdata.reverse!.map {|p,v|
		@clabels.push(p.to_s)
		@cvalues.push(v)}
	puts 'Labels:'
	puts @clabels.to_s	
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
  	@project.category = "Archived"
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
