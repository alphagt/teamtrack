class AccountsController < ApplicationController
  before_action :set_account, only: [:addInviteCode, :show, :edit, :update, :destroy]

  # GET /accounts
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  def create
    @account = Account.new(account_params)

    if @account.save
      #bootstrap default settings and admin account?
      #put admins in the account
      pa = User.find_by_id(@account.primary_admin_id)
      pa.join_account = @account.id
      pa.save
      if @account.secondary_admin_id.present?
      	sa = User.find_by_id(@account.secondary_admin_id)
      	sa.join_account = @account.id
      	sa.save
      end
      
      #Seed required Account Settings
      #CoreSettings
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'sys_names', :value => "project", :displayname => "Project", 
			:description => 'Custom field for menu name of the Project element in the system.  Admin can modify the display name but not delete this setting or add additional instances'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'sys_names', :value => "initiative", :displayname => "Initiative", 
			:description => 'Custom field for menu name of the Initiative element in the system.  Admin can modify the display name but not delete this setting or add additional instances'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'sys_names', :value => "service", :displayname => "Service", 
			:description => 'Custom field for menu name of the System element in the system.  Admin can modify the display name but not delete this setting or add additional instances'
		set.save
		puts 'added ' << set.key
# 		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'fy offset', :value => "0", :displayname => "Fiscal Year offset weeks", 
# 			:description => 'Custom field for menu name of the System element in the system.  Admin can modify the display name but not delete this setting or add additional instances'
# 		set.save
# 		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'sys_names', :value =>'fy offset', :displayname => "0", 
			:description => 'Defines the number of weeks difference between week 1 of the calendar year and week 1 of the fiscal year'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'p_cust_1', :value => "category", :displayname => 'category',
			:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with p_cust_1 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'p_cust_2', :value => "rtm", :displayname => 'rtm', 
			:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with p_cust_12 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'p_cust_3', :value => "division", :displayname => 'division',
			:description => 'Custom field for projects.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with p_cust_3 as the key for those settings.'
		set.save
		puts 'added ' << set.key

		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'p_cust_4', :value => "priority", :displayname => 'OKR',
			:description => 'Custom field for priority.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with p_cust_4 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'ts_cust_1', :value => "sgroup", :displayname => 'Service group',
			:description => 'Custom field for tech systems.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with ts_cust_1 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'ts_cust_2', :value => "stype", :displayname => 'Service type', 
			:description => 'Custom field for tech systems.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with ts_cust_1 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'u_cust_1', :value => 'etype', :displayname => 'Employee Type', 
			:description => 'Custom field for users.  Admin can define visible name by setting displayname on this setting.  
				picklist values can be added to settings with ts_cust_1 as the key for those settings.'
		set.save
		puts 'added ' << set.key
		set = Setting.create!  :account_id => @account.id, :stype => 0, :key => 'u_cust_2', :value => 'ecat', :displayname => 'Employee Category', :description => 'Custom field for users.  Admin can define visible name by setting displayname on this setting.  picklist values can be added to settings with ts_cust_1 as the key for those settings.'
		set.save
		puts 'added ' << set.key
      
      redirect_to @account, notice: 'Account was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /accounts/1
  def update
    if @account.update(account_params)
      redirect_to @account, notice: 'Account was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /accounts/1
  def destroy
    @account.destroy
    redirect_to accounts_url, notice: 'Account was successfully destroyed.'
  end
  
  # GET /accounts/:id/addInviteCode
  def addInviteCode
  	errMsg = "FAILED to create Invite Code!"
  	note = ""
  	#enforce limit of 5 invite codes per account
  	if params[:note].present? then
  		note = params[:note]
  	end
  	if @account.invitecodes.current.count < 5 then
  		@ic = InviteCode.create_new_code(@account,note)
  	else
  		errMsg = "Max number of invite codes reached!"
  	end
  	
  	#clean up any expired ICs
  	numdel = InviteCode.delete(@account.invitecodes.expired.pluck(:id))
  	puts "Deleted " + numdel.to_s + " expired invite codes"
  	if @ic != nil then
  		redirect_back(fallback_location: root_path, notice: 'Invite Code Created: ' + @ic.code)
  	else
  		redirect_back(fallback_location: root_path, notice: errMsg)
  	end
  end
  
  # GET /accounts/removeInviteCode
  def removeInviteCode
  	puts "Remove Invite Code: " + params[:code]
  	InviteCode.find_by_code(params[:code]).destroy
  	redirect_back(fallback_location: root_path, notice: 'Invite Code Removed: ')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_params
      params.require(:account).permit(:name, :email, :primary_admin_id, :secondary_admin_id, :active, :termdate, :userquota, :invitecodes)
    end
end
