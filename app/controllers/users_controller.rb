class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_manager, :except => [:team, :show, :extendteam]
	before_filter :require_verified, :except => [:show]
		
  def index
  	puts "In UserController - Index"
  	@users = User.order("manager_id,name")
  end

  def show
  	 puts "Looking Up User Number:"
  	 #puts params[:id]
     @user = User.find(params[:id])
  end
  
  # GET /users/:id/manage
  def manage
  	@user = User.find(params[:id])
  end
  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new
	puts 'In Users#New controller'
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
  	if User.find_by_name(params[:name])
  		@user = false
  		redirect_to users_path, notice: 'User Already Exists.'
  	else
    	@user = User.create_new_user(params[:user][:name], params[:user][:email], params[:user][:manager_id], params[:user][:password])
    end
    puts "RESULTS:::"
    puts @user
    respond_to do |format|
      if @user
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render json: User.find_by_name(params[:name]), status: :created, location: User.find_by_name(params[:name]) }
      else
      	@user = User.new
        format.html { redirect_to users_path, notice: 'FAILED to create user.' }
        format.json { render json: User.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /users/:id/team
  def team
  	@manager = User.find(params[:id])
  	@manager_string = 'For ' + @manager.name
  	if @manager.impersonates then
  		@manager = @manager.impersonates
  		@manager_string = '[On Behalf Of] ' + @manager.name	
  	end
  	puts 'TEAM CONTROLER, manager is'  	
  	puts @manager_string
  end
  
  # GET /user/:id/extendteam
  def extendteam
  	@manager = User.find(params[:id])
  	puts 'In ExtendTeam Controller Method'
  	respond_to do |format|
      if view_context.extend_team(@manager) == 0
        format.html { redirect_to team_user_path(@manager), notice: 'Assignments were successfully extended.' }
        format.json { render json: @manager, status: :extended, location: team_user_path(@manager) }
      else
        format.html { render action: "team" }
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
  	puts params
	rcode =1
	mUser = User.find(params[:id])
	if mUser.subordinates.length > 0 then
		rcode = 2
	else
		mUser.name += ' Ex'
		mUser.manager = User.find_by_name("ExEmployeeMgr") #special user for collecting x employees under
		mUser.admin = false
		mUser.is_manager = false
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
        if rcode = 2
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
	puts "IN USER - Update method"
    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
