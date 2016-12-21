class TechSystemsController < ApplicationController
  before_filter :authenticate_user!
	before_filter :require_verified
	before_filter :require_admin,  :except => [:index, :show]
  
  def index
  	@techsystems = TechSystem.order("qos_group", "name")
  	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  def new
  	@system = TechSystem.new
	
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
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
  	respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @system }
    end
  end
  
  # PUT /tech_system/1
  # PUT /tech_system/1.json
  def update
    @system = TechSystem.find(params[:id])
	puts 'In Update Controler Method'
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
