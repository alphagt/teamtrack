class SettingsController < ApplicationController
  before_action :set_setting, only: [:show, :edit, :update, :destroy]

  # GET /settings
  def index
    if params[:sysadmin].present? then
    	@settings = Setting.all
    	@sysadmin = true
    else
    	@settings = Setting.non_core
    	@sysadmin = false
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
  	puts params
    s = Setting.find(params[:id])
    newVal = params[:setting][:value]
    val = newVal.split(".")
    puts val
    
    if val.length > 1 then
    	if val[1].include?("ex") && params[:tags][:ex] == "0" then
    		#need to remove the excludes tag
    		newVal = val[0]
    	end
    	if val[1].include?("al") && params[:tags][:all] == "0" then
    		#need to remove allocate tag
    		newVal = val[0]
    	end
    end
    
    #exclude takes precendence.  You cannot allocate an exluded value
    if params[:tags][:ex] == "1" && newVal.split(".").length == 1  then
    	newVal += ".exclude"
    else
    	if params[:tags][:all] == "1" && newVal.split("x").length == 1 then
    		newVal += ".allocate"
    	end
    end

    if s.value == "fy offset" then
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
    	if s.key = "rtm" && s.value != params[:setting][:value] then
    		#value changes so need to update project attributes where appropriate
    		Project.where("rtm = ?", s.value).update_all(rtm: params[:setting][:value])
    	end
    	if s.key = "category" && s.value != params[:setting][:value] then
    		#value changes so need to update project attributes where appropriate
    		Project.where("category = ?", s.value).update_all(category: params[:setting][:value])
    	end
    	#modify value to include tags if required
    	if params[:setting][:value] != newVal then
    		@setting.value = newVal
    		@setting.save
    	end
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
