class AssignmentsController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_admin, :except => [:new, :create, :update, :extend, :edit, :destroy]
	before_filter :require_verified
	
  # GET /assignments
  # GET /assignments.json
  def index
	if params[:wk].present?
		@wk = params[:wk].to_i
	else
		@wk = view_context.current_week().to_i
	end
	puts "target week for Assignments"
	puts @wk
	
	@tperiod = view_context.current_fy().to_f + (@wk.fdiv(100).round(3))
	puts "Target Period for Assignments"
	puts @tperiod.to_s
		
  	@assignments = Assignment.where('set_period_id = ?', @tperiod).order("project_id,set_period_id DESC,user_id")
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
    puts 'IN NEW CONTROLER'
    #puts params.to_s
    if params.has_key?(:assignment)
    	@assignment = Assignment.new
    	@assignment.assign_attributes(params[:assignment])
    else
    	@assignment = Assignment.new 
    end
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
  	@error = nil
    #convert to set_period_id
    puts 'create assignment with date:'
    puts params[:assignment][:set_period_id].to_s
    @inputDate = Date.parse(params[:assignment][:set_period_id])
#     puts @inputDate.to_s
    params[:assignment][:set_period_id] = view_context.period_from_date(@inputDate)
    
    #handle in-line user creation
    puts params[:newuser]
    if params[:newuser][0][:name].length > 0 
    	puts "in-line User Create - " + params[:newuser][0][:name]
    	if params[:assignment][:tech_sys_id].blank?
    		#Try to use managers default system
    		if !current_user.default_system_id.blank? 
#     			puts 'Using managers default system'
    			params[:assignment][:tech_sys_id] = current_user.default_system_id
    		else
#     			puts 'cant set system id from any defaults'
    			@error = 'No Default System Defined'
    		end
    	end
    	if @error.nil?
# 			puts 'No Errors, Creating User'
			@fakeEmail = params[:newuser][0][:name].hash.to_s + 'temp@adobe.com'
# 			puts @fakeEmail
 
			@nUser = User.create! :name => params[:newuser][0][:name], 
				:email =>  @fakeEmail, :verified => false, 
				:password => 'abc123', :password_confirmation => 'abc123', :manager_id => current_user.id, 
				:default_system_id => params[:assignment][:tech_sys_id], :admin => false,
				:org => current_user.org,
				:etype => params[:newuser][0][:etype],
				:category => params[:newuser][0][:category]
			@nUser.save
			puts "INLINE USER CREATED"
			puts @nUser.to_s
			params[:assignment][:user_id] = @nUser.id
		end
    end 

    #Apply default system
#     puts 'CHECK tech system'
    #puts params[:assignment]
    if params[:assignment][:tech_sys_id].blank?
    	puts 'FOUNTD NIL SYSTEM'
    	#puts 'DEFAUL SYSTEM ID --'
    	dsysid = ""
    	if !params[:assignment][:user_id].blank?
    		dsysid = User.find_by_id(params[:assignment][:user_id]).default_system_id
    	end
    	#puts dsysid
    	if !dsysid.nil?
    		params[:assignment][:tech_sys_id] = dsysid
    	else
    		#Fail Update
    		puts 'ERROR SAVING NEW ASSIGNMENT - No Default System Defined for User'
    		@error = "No Default System Defined"
    	end
    end
    
    @assignment = Assignment.new(params[:assignment])
    @usecweek = true
	if @assignment.project.under_budget(@assignment.set_period_id) then
		@assignment.is_fixed = true
		#puts 'FIXED - TRUE'
	else
		@assignment.is_fixed = false
		#puts 'FIXED - FALSE'
	end
    respond_to do |format|
      if @error.nil? && @assignment.save
        format.html { redirect_to @assignment, notice: 'Assignment was successfully created.' }
        format.json { render json: @assignment, status: :created, location: @assignment }
      else
      	puts 'ERROR SAVING NEW ASSIGNMENT'
      	puts @assignment.errors.to_h[:project_id]
      	if @error.nil? then @error = @assignment.errors.to_h[:project_id] end
        format.html { redirect_to new_assignment_path(:assignment => params[:assignment]),  alert: 'Assignment Failed: ' + @error  }
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assignments/1
  # PUT /assignments/1.json
  def update
    #covert date to setperiod id
    @inputDate = Date.parse(params[:assignment][:set_period_id])
    params[:assignment][:set_period_id] = view_context.period_from_date(@inputDate)
    #update assignment
    @assignment = Assignment.find(params[:id])
	@newuser = User.new
# 	puts 'update assignment'
# 	puts params.to_s
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
#   	puts 'In Extend Controller Method'
  	respond_to do |format|
      if Assignment.extend_by_week(@assignment)
        format.html { redirect_to user_path(@assignment.user, history_scope: 'all'), notice: 'Assignment was successfully extended.' }
        format.json { render json: @assignment, status: :extended, location: @assignment.user }
      else
        format.html { redirect_to @assignment.user, notice: 'Failed to Extend!'}
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end
end
