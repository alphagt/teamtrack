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
  
  # GET /accounts/1/addInviteCode
  def addInviteCode
  	errMsg = "FAILED to create Invite Code!"
  	#enforce limit of 5 invite codes per account
  	if @account.invitecodes.current.count < 5 then
  		@ic = InviteCode.create_new_code(@account)
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
