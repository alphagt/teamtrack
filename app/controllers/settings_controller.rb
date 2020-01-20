class SettingsController < ApplicationController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  # GET /settings
  def index
    if params[:sysadmin].present? then
    	@settings = Setting.all
    else
    	@settings = Setting.non_core
    end
  end

  # GET /settings/1
  def show
  end

  # GET /settings/new
  def new
    @setting = Setting.new
    if params[:sysadmin].present? then
    	@sysadmin
    end
  end

  # GET /settings/1/edit
  def edit
  	@coresetting = false
  	if params[:sysadmin].present? then
  		@sysadmin = true
  	end
  	if Setting.find(params[:id]).stype == 0 || Setting.find(params[:id]).key == "sys_names" then
  		@coresetting = true
  	end
  end

  # POST /settings
  def create
    @setting = Setting.new(setting_params)
	@setting.ordinal = view_context.next_ordinal_for(@setting.key)
	@setting.stype = 1
    if @setting.save
      redirect_to @setting, notice: 'Setting was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /settings/1
  def update
    if Setting.find(params[:id]).value == "fy offset" then
    	@old_offset = Setting.find(params[:id]).displayname.to_i
    	@new_offset = (params[:setting][:displayname]).to_i
#     	puts "new Offset ?", @new_offset
    	@dif = @old_offset - @new_offset
    	 #do something to update existing assignments in the current fy
      	asnPerDate = Assignment.select("set_period_id").distinct.pluck(:set_period_id)
      	puts "Date Correction Update Quant: ?", asnPerDate.count
      	asnPerDate.each do |a|
#       	puts 'IN Update Assignments Block'
#       	oldP = a.set_period_id
#       	puts oldP
      		d = view_context.period_to_date(a)
#       	puts d.to_s
      		newP = view_context.period_from_date(d,@new_offset)
#       	puts newP
      		Assignment.where("set_period_id = ?", a).update_all(set_period_id: newP)
      	end
    end
    if @setting.update(setting_params)
      redirect_to @setting, notice: 'Setting was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /settings/1
  def destroy
    @setting.destroy
    redirect_to settings_url, notice: 'Setting was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def setting_params
      params.require(:setting).permit(:key, :ordinal, :value, :stype, :displayname, :description)
    end
end
