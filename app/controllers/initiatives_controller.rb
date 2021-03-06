class InitiativesController < ApplicationController
  before_action :set_initiative, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!
  before_filter :require_verified
  before_filter :require_admin

  # GET /initiatives
  def index
  	sname = view_context.display_name_for('sys_names', 'initiative').pluralize()
    if params[:fy].present?
		if params[:fy].downcase == 'all'
			@initiatives = Initiative.all
    		@fy = 'All'
    		@summary = sname + ' for all Fiscal Years - '
    	else
			@initiatives = Initiative.active.for_year(params[:fy])
    		@fy = params[:fy].to_i
    		@summary = sname + ' for FY ' + @fy.to_s + ' - '
    	end
	else
		@initiatives = Initiative.active.for_year(view_context.current_fy)
    	@fy = view_context.current_fy
    	@summary = sname + ' for FY ' + @fy.to_s + ' - '
	end
    
    puts 'Initiatives#Index - count'
    puts @initiatives.count
    puts @fy
    
    @fy_list = view_context.fy_list()
    
    cweek = view_context.current_week()
    
#     @cdata = @initiatives.map {|e| [e.name,e.total_effort_weeks(cweek).to_d.round, 
#     	e.current_effort_weeks(view_context.current_period).to_d.round]}
    
    #Cache Implemenation
    ckey = "InitativesData-" + cweek.to_s
  	if params[:nocache] == 'true' then
		use_cache = false
	else
		use_cache = true
	end
	cache_hit = true

	@cdata = Rails.cache.fetch("#{ckey}", expires_in: 4.days, force: !use_cache) do 
			puts "Write initiative data to cache: " + ckey
			cache_hit = false
			Rails.cache.delete_matched("#{ckey}")
			 @cdata = @initiatives.map {|e| [e.name,e.total_effort_weeks(cweek).to_d.round, 
    			e.current_effort_weeks(view_context.current_period).to_d.round]}
		end
    #****************
    puts @cdata
    @clabels = @cdata.map {|i| i[0].truncate(11)}
    @cvals= @cdata.map {|i| i[1].round(2)}
    @wvals = @cdata.map {|i| i[2].round(2)}
    
    #Get Summary Data Ready
    @sumEffort = @cvals.sum
    
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @initiatives }
    end
  end

  # GET /initiatives/1
  def show
  	@initiative = Initiative.find(params[:id])
  	@projects = Project.for_initiative(params[:id])
  	
  	#Prep Chart Data for past 12 weeks of effort
	@clabels = []
	@cvalues = []
	@cdata = Assignment.where('set_period_id BETWEEN ? AND ? AND project_id IN (?)', (view_context.current_period.to_d - 0.12).round(2).to_s, 
		view_context.current_period.to_s, @projects.pluck(:id)).group(:set_period_id).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'Chart Data'
	puts @cdata
	@clabels = @cdata.to_h.keys.map{|e| "week " + view_context.week_from_period(e).to_s}
	@clabels.sort!
	@cvalues = @cdata.to_h.values
# 	puts 'Labels:'
# 	puts @clabels.to_s	
	#Data for projects pie chart
	@cdata = Assignment.where('set_period_id = ? AND project_id IN (?)', 
		view_context.current_period, @projects.pluck(:id)).group(:project).sum(:effort).map{|a|[a[0],a[1].to_i.round(2)]}
	@slabels = @cdata.to_h.keys.map{|e| if !e.nil? then e.name.truncate(11) else "TBD" end}
	@svalues = @cdata.to_h.values	
		
	#End prep chart data
	
  	 respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @initiative }
    end
  end

  # GET /initiatives/new
  def new
    @initiative = Initiative.new
    
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @initiative }
    end
  end

  # GET /initiatives/1/edit
  def edit
  	@initiative = Initiative.find(params[:id])
    @subprilist = @initiative.subprilist
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @initiative }
    end
  end

  # POST /initiatives
  def create
    @initiative = Initiative.new(initiative_params)

    respond_to do |format|
      if @initiative.save
        format.html { redirect_to @initiative, notice: 'Initiative was successfully created.' }
        format.json { render json: @initiative, status: :created, location: @initiative }
      else
        format.html { render action: "new" }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /initiatives/1
  def update
    @initiative.subprilist = params["initiative"]["subprilist"]
    if @initiative.update(initiative_params)
      redirect_to @initiative, notice: 'Initiative was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /initiatives/1
  def destroy
    @initiative.destroy
    redirect_to initiatives_url, notice: 'Initiative was successfully destroyed.'
  end

  # GET /initiatives/1/archive
  def archive
  	@initiative = Initiative.find(params[:id])
  	@initiative.active = false
  	respond_to do |format|
      if @initiative.save
        format.html { redirect_to @initiative, notice: 'Initiative was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "archive" }
        format.json { render json: @initiative.errors, status: :unprocessable_entity }
      end
    end
  end
  	
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_initiative
      @initiative = Initiative.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def initiative_params
      params.require(:initiative).permit(:fiscal, :name, :description, :active, :tag, 
      :subprilist)
    end
end
