class UsersController < ApplicationController
	before_filter :authenticate_user!
	before_filter :require_admin, :except => [:team, :show]
	before_filter :require_verified, :except => [:show]
		
  def index
  	puts "In UserController - Index"
  	@users = User.all
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
  
  # POST /projects
  # POST /projects.json
  def createemp
  	puts 'TRY THIS:'
  	puts params[:user][:name]
    @user = User.create_new_user(params[:user][:name], params[:user][:email], params[:user][:manager_id], params[:user][:password])
    puts "RESULTS:::"
    puts @user
    respond_to do |format|
      if @user
        format.html { redirect_to users_path, notice: 'User was successfully created.' }
        format.json { render json: User.find_by_name(params[:name]), status: :created, location: User.find_by_name(params[:name]) }
      else
        format.html { render action: "new" }
        format.json { render json: User.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # GET /users/:id/team
  def team
  	@manager = User.find(params[:id])
  end
  
  #GET /users/:id/verify
  def verify
  	@u = User.find(params[:user_id])
  	@u.verified = true
  	@u.save
  	redirect_to users_path 
  end
  
  # PUT /user/1
  # PUT /user/1.json
  def update
    @user = User.find(params[:id])

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
