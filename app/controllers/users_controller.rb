class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_manager, :except => [:team, :show, :extendteam]
	before_filter :require_verified, :except => [:show]
		
  def index
  	puts "In UserController - Index"
  	@exId = User.find_by_name("ExEmployeeMgr").id
  	
  	if params[:scope] == 'all'
		@users = User.ordered_by_name
	else
  		@users = User.where('users.id != ?', @exId).ordered_by_manager
  	end
  end

  def show
  	 puts "Looking Up User Number:"
  	 #puts params[:id]
     @user = User.find(params[:id])
     #scope the assignment history per params
     if params[:history_scope] == 'all'
     	@scope = "all"
     	@ahistory = @user.assignments.order("set_period_id DESC")
     else
     	@scope = ""
     	if view_context.current_week > 8 then
	     	@ahistory = @user.assignments.recent(view_context.current_period - 0.08)
	    else
	    	@ahistory = @user.assignments.recent(current_period.floor)
	    end
     	puts "TEST TEST"
     	puts (view_context.current_period - 0.04).to_s
     end
  end
  
  # GET /users/:id/manage
  def manage
  	@user = User.find(params[:id])
  	@org = @user.org
  end
  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
    @org = current_user.org
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end
  
  #GET /users/:id/reset
  def reset
  	@user = User.find(params[:id])
  	@user.password = 'password'
  	respond_to do |format|  	
		if @user.save then
			format.html { redirect_to users_path, notice: 'Password was reset' }
			format.json { render json: User.find(params[:id]), status: :Updated, location: users_path}
		  else
			format.html { render action: "index" }
			format.json { render json: User.errors, status: :unprocessable_entity }
		end
  	end
  end
  # POST /projects
  # POST /projects.json
  def createemp
  	puts 'TRY THIS:'
  	puts params[:user][:name]
	@user = User.create_new_user(params[:user][:name], params[:user][:email], 
		params[:user][:manager_id], params[:user][:password])
	@user.ismanager = params[:user][:ismanager]
	@user.default_system_id = params[:user][:default_system_id]
	@user.admin = params[:user][:admin]
	@user.org = User.find_by_id(params[:user][:manager_id]).org
	puts "RESULTS:::"
	puts @user
	
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render json: User.find_by_name(params[:name]), status: :created, location: User.find_by_name(params[:name]) }
      else
        format.html { redirect_to users_path, notice: 'FAILED to create user: ' + @user.errors.to_h[:notice] }
        format.json { render json: User.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /users/:id/team
  def team
  
  	require 'gchart'
  	
  	@manager = User.find(params[:id])
  	@manager_string = 'For ' + @manager.name
  	if @manager.impersonates then
  		@manager = @manager.impersonates
  		@manager_string = '[On Behalf Of] ' + @manager.name	
  	end
  	
  	if params.has_key?(:period) then
  		pparts = params[:period].split(".")
  		puts "Passed in Period Parts " + pparts.to_s
  		@target_period = view_context.period_from_parts(pparts[0],pparts[1])
  	else
  		@target_period = view_context.current_period
  	end
  	puts "target period: " + @target_period.to_s
  	
  	ckey = @manager.id.to_s + "-" + view_context.week_from_period(@target_period).to_s
  	ctime_stamp = User.find(@manager.id).updated_at
  	if params[:nocache] == 'true' then
		use_cache = false
	else
		use_cache = true
	end
	cache_hit = true
  	if params[:showEx] == 'true' then
#   		puts 'Foud ShowEx Param'
		@user_list = view_context.all_subs(@manager.id, true)
	else
		@user_list = Rails.cache.fetch("#{ckey}:#{ctime_stamp}/ulist", expires_in: 24.hours, force: !use_cache) do 
			puts "Write ulist to cache: " + ckey
			cache_hit = false
			Rails.cache.delete_matched("#{ckey}:*:/ulist")
			view_context.all_subs(@manager.id)
		end
	end
	if cache_hit
		puts "Found User List in Cache for - " + ckey
	end
	
	#capture number of managers with no assignments to add to 'overhead' total
	@mgrs_count = 1
	@user_list.each do |u|
		if u.ismanager && view_context.current_assignment(u, @target_period).count < 1 then
			@mgrs_count += 1
		end
	end
	puts "Team-Ctrlr: Mgr Count: " + @mgrs_count.to_s
	@tm_count = @user_list.count
	puts "Team-Ctrlr: User Count: " + @tm_count.to_s
	
	c_assignments = Assignment.includes(:project).where("assignments.set_period_id = ? AND assignments.user_id IN (?)",
		@target_period, @user_list.map{|u| u.id}).references(:project).where("projects.active = true") 
	puts "AggAssignments -- " + c_assignments.count.to_s
	#Calulations for week summary
	
	@overhead_effort = 0
	@total_effort = 0
	cache_hit = true	
	## Total Effort & Overhead

	if @tm_count > 10 
		#lets use cach for the calcs
		cVal = Rails.cache.fetch("#{ckey}:#{ctime_stamp}/teamstats", expires_in: 24.hours, force: !use_cache) do
			puts "Write teamstats to Cache - " + ckey
			Rails.cache.delete_matched("#{ckey}:*:/teamstats")
			cache_hit = false
			c_assignments.each do |a|
					@total_effort += a.effort
					if a.project.category == "Overhead"
						@overhead_effort += a.effort
					end	
			end
			[@total_effort, @overhead_effort]
		end
	else
		cache_hit = false
		c_assignments.each do |a|
				@total_effort += a.effort
	# 			puts "Calc AssignDetails for: " + u.name + "-" + a.id.to_s
	# 			puts "Calc AssignDetails period: " + a.set_period_id.to_s
	# 			puts "Calc AssignDetails Cat: " + a.project.category
	# 			puts "Calc AssignDetails Eff: " + a.effort.to_s
				if a.project.category == "Overhead"
					@overhead_effort += a.effort
				end	
		end
	end
	if cache_hit
		puts "Found teamstats in cache - " + ckey
		@total_effort = cVal[0]
		@overhead_effort = cVal[1]
	end
	
	@overhead_effort += @mgrs_count
# 	puts "OH Percent"
# 	puts @overhead_effort.to_s + "/" + @tm_count.to_s
	@oh_pct = ((@overhead_effort/@tm_count) * 100).round.to_s
	
	#Calc for allocation table
	@cfdata = c_assignments.group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'Effort by Cat'
	puts @cfdata.to_s
	@clabels = @cfdata.to_h.keys
	@clabels.sort!
	@cvals = @cfdata.to_h.values
	
	
  	@currentmgr = ""
  	puts 'TEAM CONTROLER, manager is'  	
  	puts @manager_string
  end
  
  # GET /user/:id/extendcurrent
  def extendCurrentAssignment
  	puts 'IN Extend Current Assignment '
  	rcode = true
  	view_context.latest(User.find(params[:id])).each do |a|
  		tmp = Assignment.extend_by_week(a)
  		puts "Extend " + a.id.to_s + " Result: " + tmp.to_s
  	end
  	respond_to do |format|
      if rcode
        format.html { redirect_to team_user_path(@current_user), notice: 'Assignments were successfully extended.' }
        format.json { render json: @current_user, status: :extended, location: team_user_path(@current_user) }
      else
        format.html { redirect_to team_user_path(@current_user), notice: 'No Assignments were extended' }
        format.json { render json: @current_user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /user/:id/extendteam
  def extendteam
  	@manager = User.find(params[:id])
  	floor = 0
		if !params[:floor].nil?
			floor = params[:floor]
		end
  	puts "In ExtendTeam Controller Method - Floor = " + floor.to_s
  	respond_to do |format|
      if view_context.extend_team(@manager, floor) > 0
        format.html { redirect_to team_user_path(@manager), notice: 'Assignments were successfully extended.' }
        format.json { render json: @manager, status: :extended, location: team_user_path(@manager) }
      else
        format.html { redirect_to team_user_path(@manager), notice: 'No Assignments were extended' }
        format.json { render json: @manager.errors, status: :unprocessable_entity }
      end
    end
  end
  
  #GET /users/:id/verify
  def verify
  	@u = User.find(params[:user_id])
  	@u.verified = true
  	@u.save
  	redirect_to users_path 
  end
  
  #PUT /user/:id/exit
  def exit
#   	puts params
	rcode =1
	mUser = User.find(params[:id])
	if mUser.subordinates.length > 0 then
		rcode = 2
	else
		mUser.name += ' Ex'
		mUser.manager = User.find_by_name("ExEmployeeMgr") #special user for collecting x employees under
		mUser.admin = false
		mUser.ismanager = false
		if mUser.save then
			rcode = 0
		end
	end
	respond_to do |format|
      if rcode == 0
        format.html { redirect_to mUser, notice: 'User was successfully removed.' }
        format.json { head :no_content }
      else
        if rcode == 1
        	format.html { redirect_to mUser, notice: 'ERROR attempting to remove user' }
        	format.json { render json: mUser.errors, status: :unprocessable_entity }
        end
        if rcode == 2
        	format.html { redirect_to team_user_path(mUser), notice: 'User has current subordinates! Reassign them before removing this user' }
        	format.json { render json: mUser.errors, status: :unprocessable_entity }
        end
      end
    end	 
  end
  
  # PUT /user/1
  # PUT /user/1.json
  def update
    @user = User.find(params[:id])
    @org = current_user.org
    #Update the user list cache for this user's manager
    
    # if @user.manager_id.to_s != params[:user][:manager_id]
#     	#update user list cache for both old and new manager
#     	puts "Wack the Cache - Manager Change"
#     	cKey = params[:user][:manager_id] + "-" + view_context.current_week.to_s
#     	if !Rails.cache.delete(cKey + "/ulist")
#     		puts "FAILED TO DELETE CACHE -" + cKey + "/ulist"
#     	end
# 		cKey = @user.manager_id.to_s + "-" + view_context.current_week.to_s
# 		if !Rails.cache.fetch(cKey + "/ulist")
# 			puts "FAILED TO DELETE CACHE -" + cKey + "/ulist"
# 		end
# 	end
	puts "IN USER - Update method - " + @user.name
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
      	puts "failed to update USER " + @user.errors.messages().to_s()
        format.html {redirect_to @user, notice: "Failed to update user!!" + @user.errors }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
