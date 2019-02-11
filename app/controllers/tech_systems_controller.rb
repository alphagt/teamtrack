class TechSystemsController < ApplicationController
  before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show]
  
  def index
  	#@techsystems = TechSystem.order("qos_group", "name")
  	@techsystems = TechSystem.by_qos
  	puts "### TechSystems Index - " + @techsystems.count
  	@current_qos = @techsystems.first().qos_group
  	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @techsystems }
    end
  end

  def new
  	@system = TechSystem.new
	
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @system }
    end
  end

  def create
  	@system = TechSystem.new(params[:tech_system])
	
    respond_to do |format|
      if @system.save
        format.html { redirect_to @system, notice: @system.name + ' System was successfully created.' }
        format.json { render json: @system, status: :created, location: @system }
      else
        format.html { render action: "new" }
        format.json { render json: @system.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
  	@system = TechSystem.find(params[:id])
  	
  	#Prep Chart Data for past 12 weeks of effort
	@clabels = []
	@cvalues = []
	@cdata = Assignment.where('set_period_id BETWEEN ? AND ? AND tech_sys_id = ?', (view_context.current_period.to_d - 0.12).round(2).to_s, 
		view_context.current_period.to_s, params[:id]).group(:set_period_id).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'Chart Data'
	puts @cdata
	@clabels = @cdata.to_h.keys.map{|e| "week " + view_context.week_from_period(e).to_s}
	@clabels.sort!
	@cvalues = @cdata.to_h.values
# 	puts 'Labels:'
# 	puts @clabels.to_s	
	#Data for projects pie chart
	@cdata = Assignment.where('set_period_id = ? AND tech_sys_id = ? AND tech_sys_id > 0', 
		view_context.current_period, params[:id]).group(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	@slabels = @cdata.to_h.keys.map{|e| if !e.nil? then e.name else "TBD" end}
	@svalues = @cdata.to_h.values	
		
	#End prep chart data
  	
  	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @system }
    end
  end
  
  # PUT /tech_system/1
  # PUT /tech_system/1.json
  def update
    @system = TechSystem.find(params[:id])
	puts "In TechSystem Update Controler Method - " + @system.name
    respond_to do |format|
      if @system.update_attributes(params[:tech_system])
        format.html { redirect_to @system, notice: 'System was successfully updated.' }
        format.json { render json: @system, status: :updated, location: @system }
      else
        format.html { render action: "edit" }
        format.json { render json: @system.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /tech_systems/1/edit
  def edit
    @system = TechSystem.find(params[:id])
  end
  
  # GET /tech_systems/1/archive
  def archive
  	@system = TechSystem.find(params[:id])
  	@system.qos_group = "Archived"
  	respond_to do |format|
      if @system.save
        format.html { redirect_to @system, notice: 'Project was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "archive" }
        format.json { render json: @system.errors, status: :unprocessable_entity }
      end
    end
  end
end
