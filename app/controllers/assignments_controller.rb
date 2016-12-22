class AssignmentsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_admin, :except => [:new, :create, :update, :extend, :edit, :destroy]
	before_filter :require_verified
	
  # GET /assignments
  # GET /assignments.json
  def index
  	
  	@assignments = Assignment.where('set_period_id > ?', view_context.current_period().to_f().floor).order("project_id,set_period_id DESC,user_id")
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
    @newuser = User.new 
    @usecweek = false  #ToReview
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
    @newuser = User.new
    if current_user.admin? then
    	@showFixedCbox = true
    end
  end

  # POST /assignments
  # POST /assignments.json
  def create
    #convert to set_period_id
    puts 'create assignment with date:'
    puts params[:assignment][:set_period_id].to_s
    @inputDate = Date.parse(params[:assignment][:set_period_id])
    puts @inputDate.to_s
    params[:assignment][:set_period_id] = view_context.period_from_date(@inputDate)
    
    #handle in-line user creation
    #puts params[:newuser].length
    if params[:newuser].length > 0 then
    	puts 'in-line User Create'
    	@fakeEmail = params[:newuser][0][:name].hash.to_s + 'temp@adobe.com'
    	puts @fakeEmail
    	@nUser = User.create! :name => params[:newuser][0][:name], 
    		:email =>  @fakeEmail, :verified => false, 
    		:password => 'abc123', :password_confirmation => 'abc123', :manager_id => current_user.id, 
    		:default_system_id => params[:assignment][:tech_sys_id], :admin => false
    	@nUser.save
    	puts @nUser
    	params[:assignment][:user_id] = @nUser.id
    end 
    puts 'converted to period:'
    puts params[:assignment][:set_period_id]
    @assignment = Assignment.new(params[:assignment])
    @usecweek = true
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
	@newuser = User.new
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
        format.html { redirect_to @assignment.user, notice: 'Failed to Extend!'}
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end
end
