class AssignmentsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_admin, :except => [:new, :create, :update, :extend, :edit]
	before_filter :require_verified
	
  # GET /assignments
  # GET /assignments.json
  def index
    @assignments = Assignment.order("project_id,set_period_id,user_id")
	@manager = current_user
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assignments }
    end
  end

  # GET /assignments/1
  # GET /assignments/1.json
  def show
    @assignment = Assignment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/:uid/new
  # GET /assignments/:uid/new.json
  def new
    @manager = current_user
    @assignment = Assignment.new
    if params[:uid] then
    	@assignment.user = User.find(params[:uid].to_s)
    	puts @assignment.user
    end
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assignment }
    end
  end

  # GET /assignments/1/edit
  def edit
    @assignment = Assignment.find(params[:id])
    if current_user.admin? then
    	@showFixedCbox = true
    end
  end

  # POST /assignments
  # POST /assignments.json
  def create
    @assignment = Assignment.new(params[:assignment])
	if @assignment.project.under_budget(@assignment.set_period_id) then
		@assignment.is_fixed = true
		puts 'FIXED - TRUE'
	else
		@assignment.is_fixed = false
		puts 'FIXED - FALSE'
	end
    respond_to do |format|
      if @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render json: @assignment, status: :created, location: @assignment }
      else
        format.html { render action: "new" }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    @assignment = Assignment.find(params[:id])

    respond_to do |format|
      if @assignment.update_attributes(params[:assignment])
        format.html { redirect_to @assignment, notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assignments/1
  # DELETE /assignments/1.json
  def destroy
    @assignment = Assignment.find(params[:id])
    u = @assignment.user
    @assignment.destroy

    respond_to do |format|
      format.html { redirect_to user_path(u) }
      format.json { head :no_content }
    end
  end
  
  # GET /assignments/1
  # GET /assignments/1.json
  def extend
  	@assignment = Assignment.find(params[:id])
  	puts 'In Extend Controller Method'
  	respond_to do |format|
      if Assignment.extend_by_week(@assignment)
        format.html { redirect_to @assignment.user, notice: 'Assignment was successfully extended.' }
        format.json { render json: @assignment, status: :extended, location: @assignment.user }
      else
        format.html { render action: "extend" }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end
end
