class UsersController < ApplicationController
	respond_to :html, :js
	before_action :authenticate_user!
	before_action :require_manager, :except => [:team, :show, :extendteam, :index]
	before_action :require_verified, :except => [:show]
		
  def index
  	puts "In UserController - Index"
  	@exId = User.find_by_name("ExEmployeeMgr").id
  	
  	if params[:org].present?
		if params[:org].downcase == 'all'
			@mgr_id = 0
		else
			@mgr_id = params[:org].to_i 
		end
	else
		@mgr_id = current_user.id
	end
	
	if current_user.superadmin
		if params[:acct].present? && params[:acct] != "-1"
			@users = User.for_account(params[:acct]).ordered_by_name
			puts "Filter by Acct ID"
		else
			@users = User.ordered_by_account.ordered_by_name
		end
		if params[:acct].present?
			@sAcct = params[:acct]
		else
			@sAcct = -1
		end
	else
		if params[:scope] == 'all' || @mgr_id == 0
			@users = User.for_account(current_user.primary_account_id).ordered_by_name
		else
  			@users = view_context.extended_subordinates(@mgr_id, true)
  		end
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
	    	@ahistory = @user.assignments.recent(view_context.current_period.floor)
	    end
     	puts "TEST TEST"
     	puts (view_context.current_period - 0.04).to_s
     end
     #data for project allocation pie chart
     @clabels = []
	 @cvalues = []
	 @cdata = @ahistory.group(:project_id).sum(:effort).map{|a|[a[0],a[1].to_i]}
	 puts @cdata.to_s
	 @clabels = @cdata.to_h.keys.map{|e| Project.find_by_id(e).name}
	 @clabels.sort!
	 @cvalues = @cdata.to_h.values
	puts @clabels.to_s
	puts @cvalues.to_s
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
    @aid = current_user.primary_account_id
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
	@mgr = User.find_by_id(params[:user][:manager_id])
	@user.primary_account_id = @mgr.primary_account_id
	if params[:user][:org].empty?
		@user.org = @mgr.org
	else
		@user.org = params[:user][:org]
	end
# 	@user.is_contractor = params[:user][:is_contractor]
	@user.isstatususer = params[:user][:isstatususer]
	@user.etype = params[:user][:etype]
	@user.category = params[:user][:category]
	
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
  	
  	@altimpl = false
  	if params.has_key?(:altimpl) && params[:altimpl] == "true" then
  		@altimpl = true
  		puts "ALT IMPLEMENTATION SIGNALED"
  	end
  	
  	@condense = false
  	if params.has_key?(:condense) && params[:condense] == "true" then
  		@condense = true
  	end
  	
  	puts "Condense Var:  " + @condense.to_s
  	
  	ckey = @manager.id.to_s + "-" + view_context.week_from_period(@target_period).to_s
  	ctime_stamp = User.find(@manager.id).updated_at
  	if params[:nocache] == 'true' then
		use_cache = false
	else
		use_cache = true
	end
	cache_hit = true
	#CURRENT IMPL FOR DERIVING ORG MEMBERSHIP
	@user_list = Rails.cache.fetch("#{ckey}:#{ctime_stamp}/ulist", expires_in: 24.hours, force: !use_cache) do 
			puts "Write ulist to cache: " + ckey
			cache_hit = false
			Rails.cache.delete_matched("#{ckey}:*:/ulist")
			@user_list = view_context.get_org(@manager.id)
		end
	
	#special handling for change in ulist format that might be wrong in cache
	if cache_hit && @user_list.length < 4 
		#need to reload it
		Rails.cache.delete_matched("#{ckey}:*:/ulist")
		@user_list = view_context.get_org(@manager.id)
	end
  	if params[:showEx] == 'true' then
#   		puts 'Foud ShowEx Param'
		@user_list[0] << User.find_by_name("ExEmployeeMgr").id
		puts "Added Ex Emp!"
		puts @user_list.to_s

	end
	#condense the detail rows if the total list length is greater than 48 [DEPRECATED]
	if !params.has_key?(:condense) && @user_list.length > 60 
		@condense = true
	end
	
	#capture number of managers with no assignments to add to 'overhead' total
	@mgrs_count = @user_list[0].count

	puts "Team-Ctrlr: Mgr Count: " + @mgrs_count.to_s
	@tm_count = @mgrs_count + @user_list[1] + @user_list[2]
	puts "Team-Ctrlr: User Count: " + @tm_count.to_s
# 	puts @user_list.map{|u| u[1].to_s + "," + u[2].name}
	puts "IDs List for Assignments Query"
	fullulist = Array.new()
	@user_list[0].map{|m| fullulist += User.find(m).subordinates.pluck(:id)}
	fullulist += @user_list[0]
	puts fullulist.to_s
	c_assignments = Assignment.includes(:project).where("assignments.set_period_id = ? AND assignments.user_id IN (?)",
		@target_period, fullulist).references(:project).where("projects.active = true") 
	puts "AggAssignments -- " + c_assignments.count.to_s
	
	#Calulations for week summary
	
	#build hash of resource statistics (probably need to cache this later)
	#fix fix to deal with settings based emp category and type matrix
	@resstats = Hash.new()
	resset = User.where("id IN (?)", fullulist)
	Setting.for_key('ecat').each do |c|
		puts c.value
		ohash = Hash.new()
		Setting.for_key('etype').each do |t|
			puts '--- ', t.value
			ohash[t.displayname] = resset.for_category(c.value).for_type(t.value).count
		end 
		@resstats[c.displayname] = ohash
	end
	 
	puts @resstats.to_s
	
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
	
# 	puts "OH Percent"
# 	puts @overhead_effort.to_s + "/" + @tm_count.to_s
	if @tm_count == 0 then
		@oh_pct = "0"
	else
		@oh_pct = ((@overhead_effort/@tm_count) * 100).round.to_s
	end
	
	#Calc for allocation table
	@cfdata = c_assignments.group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'Effort by Cat'
	puts @cfdata.to_s
	cdataH = calc_chart_data(@cfdata)
	@clabels = cdataH.keys.map { |k| k.split(".")[0]}
	@cvals = cdataH.values
	
  	#@currentmgr = ""
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
		mUser.orgowner = false
		mUser.org = 'ExOrg'
		
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
    #@org = current_user.org
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
      if @user.update_attributes(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
      	puts "failed to update USER " + @user.errors.messages().to_s()
        format.html {redirect_to @user, notice: "Failed to update user!!" + @user.errors }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  
  #GET /users/teamlist
  def teamlist
  	puts "TEAMLIST CONTROLER METHOD"
  	puts params.to_s
  	@mgr = User.find(params[:id])
	@subclass = params[:tname]
	@baseorg = params[:baseorg]
	@direct = params[:isdirect]
	@period = params[:tperiod]

	puts "@direct = " + @direct
	respond_to do |format|
		#format.html {render 'teamlist', :layout=>false}
		format.js {render 'teamlist', :content_type => 'text/html', :layout=>false}
	end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :admin, :password_confirmation, :remember_me, :is_contractor,
      	:default_system, :default_system_id, :verified, :isstatususer, :org, :orgowner,
      	:ismanager, :impersonates, :impersonate_manager, :manager, :manager_id, :etype, 
      	:category, :primary_account_id, :superadmin)
    end
  
end
