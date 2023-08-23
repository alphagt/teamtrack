class ProjectsController < ApplicationController
	before_action :authenticate_user!
	before_action :require_verified
	before_action :require_admin,  :except => [:index, :show] 
	


  def dateTest
  
    #  USED FOR DEBUGGING DATE TO PERIOD CALCS - TEST ONLY
  	#*****************************
	puts "Testing 1 Jan 2019 ...."
	d = Date.new(2019,1,1)
	puts d.cweek	
  	puts view_context.period_from_date(d).to_s
  	
  	puts "Testing 2 July 2018 ...."
	d = Date.new(2018,7,2)
	puts d.cweek	
  	puts view_context.period_from_date(d).to_s
	
	puts "Testing 27 June 2019 ...."
	d = Date.new(2019,6,27)
	puts d.cweek	
  	puts view_context.period_from_date(d).to_s
	#*****************************
  end
  
 def get_autocomplete_items(parameters)
 	items = Project.for_account(current_user.primary_account_id).
 		active.select("id, name").order("name")
 end
  
  # GET /projects
  # GET /projects.json
  def index
	
	require 'gchart'
	
	#Full Project list used for aggregate statistics
	@aid = current_user.primary_account_id
	@allProjects = Project.for_account(@aid).by_category
	
	
	#Param Handling
	
	#Optional :org specifies a manager ID, default is current signed in user
	#     Special case for value set to 0 - will aggregate all projects in the system ('All')
	if params[:org].present?
		if params[:org].downcase == 'all'
			@mgr_id = 0
		else
			@mgr_id = params[:org].to_i 
		end
	else
		@mgr_id = current_user.id
	end
	puts "INDEX: MGR ID = "
	puts @mgr_id.to_s
	
	#Current FY Data
	
	if params[:fy].present?
		@fy = params[:fy].to_i
	else
		@fy = view_context.current_period().to_i
	end
	puts "Projects for FY: "
	puts @fy
	
	#Reset mgr_id to 0 if FY is not current FY to include all active and closed projects in view
	if @fy != view_context.current_fy() 
		@mgr_id = 0
		@scopeall = true
		#SET MGR TO ZERO DUE TO PREVIOUS FY, for anything other than current FY always show data unfiltered
	end
	
	#Optional :setq specifies a specific quarter number, defaul it current quarter
	if params[:setq].present?
		@setq = params[:setq].to_i
	else
		@setq = view_context.current_quarter()
	end
	puts @setq
	
	if @mgr_id != 0 && User.find(@mgr_id).orgowner
		@include_indirect = true
	else
		@include_indirect = false
	end
	
	#Optional :scope ('all' - Active and Closed projects, 'active' - active projects only [default]
	#     Sets the @projects variable for use in generating list of in scope projects for the view
	if (!params[:scope].present? && !@scopeall) || params[:scope] == 'active' 
		if @mgr_id == 0 || (current_user.isstatususer? && @mgr_id == current_user.id)  #called with no org selected by status user
			uList = []
			@projects = @allProjects.active
		else
			uList = view_context.all_subs_by_id(@mgr_id, @include_indirect, @aid)
			@projects = Project.active.for_account(@aid).for_users(uList).by_category
		end
	else
		@scopeall = true	
		if params[:scope] == 'all' || @fy != view_context.current_fy()
			if @mgr_id == 0 || (current_user.isstatususer? && @mgr_id == current_user.id)
				uList = []
				@projects = @allProjects
			else
				uList = view_context.all_subs_by_id(@mgr_id, @include_indirect, @aid)
				@projects = Project.for_account(@aid).for_users(uList).by_category
			end	
		end
	end
	
	#Hanlde Empty project list
	

	if params[:showvals] == '1'
		@showVals = true
	else
		@showVals = false
	end
	
	if params[:statsview] == '1' || current_user.isstatususer? || current_user.admin?
		@statsView = true
	else
		@statsView = false
	end
	
	if uList.count == 0  then
		uList = User.for_account(@aid).pluck(:ID)
	end
	
#	#################################	
#	#Calculate and group fixed effort totals for chart
	
	@cfdata = Assignment.includes(:project).where('projects.category != ? AND set_period_id BETWEEN ? and ? AND projects.id IN (?) AND assignments.user_id IN (?)', 
		'Overhead', @fy.to_s, (@fy + 1).to_s, @allProjects.pluck(:id), uList).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
	puts 'YTD Effort by Cat'
	puts @cfdata.to_s

	@clabels_ytd = []
	@cvals_ytd = []
	
	if @cfdata.length > 0
		combinedytd = calc_chart_data(@cfdata)
		##### Finalize var to support chart creation ######
		@cvals_ytd = combinedytd.values
		puts "YTD Total"
		ytd_total = @cvals_ytd.sum
		puts ytd_total
		combinedytd.map do |key, val|
			#handle empty set
			if val > 0 then
				pVal = (val.to_f/ytd_total * 100).round().to_s
			else
				pVal = "0"
			end
			#@clabels_ytd << view_context.display_name_for("category",key).truncate(11) + "-" + pVal + "%"	
			@clabels_ytd << key + "-" + pVal + "%"
		end	
	end
	puts "## YTD Hash labels, values "
	puts @clabels_ytd.to_s
	puts @cvals_ytd.to_s
	
		
	#Current Quarter Data
	case @setq #determin start end week number for each quarter
	when 1
		@eWeek = view_context.period_from_parts(@fy,13)
		@sWeek = @fy.to_s
# 		puts 'max week for period'
# 		puts @eWeek
	when 2
		@eWeek = view_context.period_from_parts(@fy,25)
		@sWeek = view_context.period_from_parts(@fy,12)
		puts 'start week for period'
		puts @sWeek.to_s
	when 3
		@eWeek = view_context.period_from_parts(@fy,37)
		@sWeek = view_context.period_from_parts(@fy,24)
		puts 'start week for period'
		puts @sWeek.to_s
	when 4
		@eWeek = view_context.period_from_parts(@fy,53)
		@sWeek = view_context.period_from_parts(@fy,36)
		puts 'start week for period'
		puts @sWeek.to_s
	end
		puts 'max week for current quarter'
		puts @eWeek

	#Select assignments for the quarter  date range that are not 'Overhead' grouped by category to display in pie chart
	@cfdata_qtd = Assignment.includes(:project).where("projects.category != ? AND set_period_id BETWEEN ? AND ? AND projects.id IN (?)", 
			'Overhead', @sWeek.to_s, @eWeek.to_s, @projects.pluck(:id)).group('projects.category').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}

	puts 'Current Quarter Effort by Cat'
	puts @cfdata_qtd.to_s
	
	combinedqtd = calc_chart_data(@cfdata_qtd)
	

	##### Finalize var to support chart creation ######
		@clabels_qtd = []
		@cvals_qtd = combinedqtd.values
		puts "QTD Total"
		qtd_total = @cvals_qtd.sum
		puts qtd_total
		combinedqtd.map do |key, val|
			#handle empty set
			if val > 0 then
				pVal = (val.to_f/qtd_total * 100).round().to_s
			else
				pVal = "0"
			end
			# @clabels_qtd << view_context.display_name_for(Setting.for_key("p_cust_1")[0].value,key).truncate(11) + "-" + pVal + "%"
			@clabels_qtd << key + "-" + pVal + "%"

		end	
		puts @clabels_qtd.to_s
	
	
	#Calculate and group RTM and Stakeholder summary data for charts
	if @statsView then
		puts "in StatsView block"
		
		#Priority Chart Data (NOTE:  May want to cache this on a weekly basis)
		cweek = view_context.current_week
		puts "Current Week is"
		puts cweek
		#get grouped effort for assignments bounded by projects and users relevant to the viewing manager
		@ctpdata = Assignment.fte_only.includes(:project).where('projects.category != ? AND projects.keyproj = false AND 
			set_period_id BETWEEN ? and ? AND projects.id IN (?) AND assignments.user_id IN (?)', 
			'Overhead', @fy.to_s, (@fy + 1).to_s, @projects.pluck(:id), uList).group(['projects.initiative_id','projects.ctpriority']).references(:project).sum(:effort).map do |a|
		
			pri_custname = Setting.for_account(@aid).for_key("p_cust_4").pluck(:value)
			pri_custname.freeze
			pri_setting = Setting.for_account(@adi).for_key(pri_custname).where("value = ?",a[0][1].to_s)
			if pri_setting.count > 0 then
				pri_display = Setting.for_account(@aid).for_key(pri_custname).where("value = ?",a[0][1].to_s).first.displayname.truncate(11)
			else
				pri_display = a[0][1].to_s.truncate(11)
			end
			puts "##### DISPLAY NAME - "
			puts pri_display
			if !a[0][0].nil? then
				i = Initiative.find(a[0][0])
				
				if !i.tag.nil? then
					#cat = a[0][1].to_s + "-" + i.tag 
					cat = pri_display + "-" + i.tag
				else
					#cat = a[0][1].to_s + "-" + i.name 
					cat = pri_display + "-" + i.name.truncate(5)
				end
			else 
				#cat = a[0][1].to_s + "-" + "NA" 
				cat = pri_display + "-" + "NA" 
			end
			[cat,(a[1].to_f/cweek).round(2)]
		end
		#add quasi-priority to array for each keyproj 
		@keyprojdata = Assignment.fte_only.includes(:project).where('projects.category != ? AND projects.keyproj = true AND
			set_period_id BETWEEN ? and ? AND projects.id IN (?) AND assignments.user_id IN (?)', 
			'Overhead', @fy.to_s, (@fy + 1).to_s, @projects.pluck(:id), uList).group(['projects.initiative_id','projects.name']).references(:project).sum(:effort).map do |a|
			if !a[0][0].nil? then
				i = Initiative.find(a[0][0])
				if !i.tag.nil? then
					cat =i.tag + "-*" + a[0][1].truncate(11).to_s
				else
					cat = i.name.truncate(11) + "-*" + a[0][1].truncate(6).to_s
				end
			else 
				cat = "NA" + "-*" + a[0][1].truncate(11).to_s  
			end
			[cat,(a[1].to_f/cweek).round(2)]
		end	
		puts "PRIORITY KEY PROJECT DATA BLOCK:"
		puts @keyprojdata.to_s
		@ctpdata += @keyprojdata
		@ctpdata.sort!
		puts "PRIORITY SUMMARY DATA BLOCK:"
		puts @ctpdata.to_s
		#End CT Priority Chart section
		
#		#######################################
#		#####   RTM Effort Cals ############
		
		rtmeffort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
			@fy.to_s, (@fy + 1).to_s, 
			Project.for_account(@aid).for_users(uList).pluck(:id)).group('projects.rtm').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		puts "combined in hash"
		puts rtmeffort.to_s

		combinedrtm = calc_chart_data(rtmeffort,'p_cust_2')

		#### set the variables used in the view for charting
		puts "FINAL RTM HASH"
		puts combinedrtm.to_s
		
		alabs = []
		combinedrtm.map do |k,v|
			alabs << view_context.display_name_for(Setting.for_account(@aid).for_key("p_cust_2")[0].value,k).truncate(11) + "-" + v.round(2).to_s #TODO - change to percent of total?
		end
		@slabels = alabs
		@sVals = combinedrtm.values	

		#Stakeholder Calcs
		# Get sum of effort grouped by stakeholder values
		psheffort = Assignment.includes(:project).where('set_period_id BETWEEN ? and ? AND projects.id IN (?)',
			@fy.to_s, (@fy + 1).to_s, 
			Project.for_account(@aid).for_users(uList).pluck(:id)).group('projects.psh').references(:project).sum(:effort).map{|a|[a[0],a[1].to_i]}
		puts "STAKEHOLDER RAW DATA"
		puts psheffort.to_s

		combinedpsh = calc_chart_data(psheffort,'p_cust_3').except("NA")

		#### set the variables used in the view for charting
		puts "FINAL PSH HASH"
		puts combinedpsh.to_s
		
		alabs = []
		combinedpsh.map do |k,v|
			alabs << view_context.display_name_for(Setting.for_account(@aid).for_key("p_cust_3")[0].value,k).truncate(11) + "-" + v.round(2).to_s #TODO - change to percent of total?
		end
		@pshlabels = alabs
		@pshVals = combinedpsh.values	

	end
	
	puts "user scoped project list:"
	puts @projects.count
	
	prj = @projects.map{ |p| [view_context.current_allocation(p,1).to_s + "_" + p.id.to_s,p] }.to_h
#	TODO - use this sort once we add grouped view on projects index view
#	@projects = prj.sort_by {|alloc,p| [p.category, -alloc]}

	@projects = prj.sort_by {|alloc,p| [alloc.split('_')[0].to_f]}.reverse
	
	puts @projects.to_h.keys
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  def import
  	require 'csv'
  	
  	#options = {:force_utf8, :strip_chars_from_headers => "s/([()])//g", :key_mapping => {:issue_key => :issue_key, :summary => :summary, :reporter => :owner}, :remove_unmapped_keys => true}
    @aid = current_user.primary_account_id
    
    tFile = params[:file]
    newproj = []
    cols = [:account_id, :active, :name, :psh, :rtm, :ctpriority, :upl_number, :owner_id, :description, :category, :fixed_resource_budget]
	fieldMappingsChecked = false
	#setup default field names hash
	iFields = Hash.new()
	iFields['name'] = 'name'
	iFields['rtm'] = 'rtm'
	iFields['upl_number'] = 'upl_number'
	iFields['description'] = 'description'
	iFields['category'] = 'category'
	iFields['owner_email'] = 'email'
	iFields['owner_name'] = 'owner'
	iFields['psh'] = 'division'
	iFields['fin_type'] = 'fin_type'
	iFields['end_date'] = 'end_date'
	iFields['ctpriority'] = 'okr'
	iFields['initiative'] = 'initiative'
	
	CSV.foreach(tFile.path, headers: true) do |r|
		puts r
		i = r.to_h.with_indifferent_access
		# puts "RAW HASH ---"
# 		puts i.keys().first.chars
		plug = i.keys().first.encode("ASCII", "UTF-8", undef: :replace)
				
		if i.keys().first != plug then
			#special handling for Jira Summary field due to ruby hash wierdness with key 'summary'
			puts "EXCEPTION - Handling reserved word key Summary"	
			i[plug.tr('?','')] = i.delete i.keys().first
			i = i.transform_keys(&:downcase)
		else
			i = r.to_h.transform_keys(&:downcase)
		end
		# puts "CLEAN HASH"
# 		puts i
		
		
		#get import settings for this tennant and add to iFields hash once on first record
		if !fieldMappingsChecked then
			cfname = Setting.for_account(@aid).find_by_key("p_cust_5").value
			puts "cfname " + cfname
			imap = Setting.for_account(@aid).for_key(cfname) #get any configured import mappings
			#check if the imported data has any filed names that are mapped
			imap.each do |h|
				f = i.select {|k,v| k.include? h.displayname.downcase}
				if !f.nil?
					iFields[h.value] = h.displayname.downcase
					puts "added " + h.displayname.downcase + " for project field " + h.value
				else
					puts "Didn't find import column for " + h.value
				end
			end
			puts "MAPPED FIELDS FOUND ===== " 
			puts iFields.to_s
			fieldMappingsChecked = true
		end
		
		#process columns with labels that match 'reserved' names: ISSUE KEY, DESCRIPTION, RTM, CATEGORY
		if iFields['upl_number'] == "issue key" then  
			#this is a jira import so trim the project key off the issue number
			puts "PROCESS JIRA ISSUE KEY"
			pid = i[iFields['upl_number']].split("-")[1].to_i || Project.for_account(@aid).pluck(:upl_number).max + 1
		else
			pid = i[iFields['upl_number']].to_i || Project.for_account(@aid).pluck(:upl_number).max + 1
		end
		#TODO - Handle possible pid collision from using jira issue key value
		desc = ""
		rtm = ""
		if i[iFields['description']] then
			desc = i[iFields['description']].truncate(150, separator: ' ')
		end
		if i[iFields['rtm']] then
			puts "Find setting value for RTM: " + i[iFields['rtm']]
			#get known picklist value associated with imported value
			s = Setting.for_account(@aid).find_by_displayname(i[iFields['rtm']])
			if !s.nil? && !s.value.nil?
				rtm = s.value
			else
			 	rtm = i[iFields['rtm']] #use found picklist val or insert the imported value as is
			end
		else #case of no explicit mapping but import has field with same custom displayname
			if i[view_context.get_cfield_name("p_cust_2")] then
				rtm = i[view_context.get_cfield_name("p_cust_2")].truncate(50)
			end
		end
		
		if i[iFields['fin_type']] then
			puts "Find setting value for fin_type: " + i[iFields['fin_type']]
			#get known picklist value associated with imported value
			s = Setting.for_account(@aid).find_by_displayname(i[iFields['fin_type']])
			if !s.nil? && !s.value.nil?
				finType = s.value
			else
			 	finType = i[iFields['fin_type']] #use found picklist val or insert the imported value as is
			end
		else #case of no explicit mapping but import has field with same custom displayname
			if i[view_context.get_cfield_name("p_cust_6")] then
				finType = i[view_context.get_cfield_name("p_cust_6")].truncate(50)
			end
		end
		
		if i[iFields['psh']] then
			puts "Find setting value for psh: " + i[iFields['psh']]
			#get known picklist value associated with imported value
			s = Setting.for_account(@aid).find_by_displayname(i[iFields['psh']])
			if !s.nil? && !s.value.nil?
				div = s.value
			else
			 	div = i[iFields['psh']] #use found picklist val or insert the imported value as is
			end
		else #case of no explicit mapping but import has field with same custom displayname
			if i[view_context.get_cfield_name("p_cust_3")] then
				div = i[view_context.get_cfield_name("p_cust_3")].truncate(50)
			end
		end
		
		if i[iFields['ctpriority']] then
			puts "Find setting value for ctpriority: " + i[iFields['ctpriority']]
			#get known picklist value associated with imported value
			s = Setting.for_account(@aid).find_by_displayname(i[iFields['ctpriority']])
			if !s.nil? && !s.value.nil?
				okr = s.value
			else
			 	okr = i[iFields['ctpriority']] #use found picklist val or insert the imported value as is
			end
		else #case of no explicit mapping but import has field with same custom displayname
			if i[view_context.get_cfield_name("p_cust_4")] then
				okr = i[view_context.get_cfield_name("p_cust_4")].truncate(50)
			end
		end
		
		if i[iFields['end_date']] then
			puts "Found value for end_date: " + i[iFields['end_date']]
			eDate = i[iFields['end_date']] #use found picklist val or insert the imported value as is
			
		else #case of no explicit mapping but import has field with same custom displayname
			if i[view_context.get_cfield_name("p_cust_7")] then
				eDate = i[view_context.get_cfield_name("p_cust_7")]
			end
		end
		puts "eDate is " + eDate.to_s 
		
		if i[iFields['category']] then
			puts "Find setting value for category: " + i[iFields['category']]
			#lookup whether the imported category value is a picklist item in teamview
			s = Setting.for_account(@aid).find_by_displayname(i[iFields['category']])
			if !s.nil? && !s.value.nil?
				cat = s.value
			else
				cat = i[iFields['category']] #associate to picklist if possible or set to imported value
			end
		end
		if cat.nil?
			puts "Empty Category Import Detected"
			cat = 'Undefined'
		end
		#ToDo - add handling for no mapping but same field name as with RTM above
		
		if i[iFields['name']] then
			pname = i[iFields['name']]
		else
			pname = "undefined"
			puts "FAILED to find project name"
		end
		
		if !i[iFields['owner_email']].blank? then
			oUser = User.for_account(@aid).for_email(i[iFields['owner_email']]) 
		else
			if !i[iFields['owner_name']].blank? then
				puts "Failed to find owner by email, checking by name: " + i[iFields['owner_name']]
				#use project owner name to try and resolve owner in teamview 
				oUser = User.for_account(@aid).find_by_name(i[iFields['owner_name']])
			end
		end
		if oUser.respond_to?(:id) then
			puts "oUser from file = " + oUser.name
			if oUser.ismanager
				oid = oUser.id
			else
				oid = oUser.manager_id || "1"
			end
		else
			oid = "1"
		end
		puts "Owner Resolved to " + User.find_by_id(oid).name
		oUser = nil
		
		#handle initiative mappings
		if !i[iFields['initiative']].blank? then
			puts "Looking up id for Initiative: " +i[iFields['initiative']]
			init = Initiative.for_account(@aid).find_by_name(i[iFields['initiative']])
			iId = nil
			if init
				iId = init.id
				puts "Mapped Initiative to: " + iId.to_s
			else 
				puts "ERROR - Non-Existent Initiative name encountered: " +  i[iFields['initiative']]
			end
		end
		
		
		puts "UID = " + pid.to_s
		tProj = Project.for_account(@aid).find_by_upl_number(pid)
		#retry using name match incase of shift in JIRA ids
		if tProj.nil? then
			tProj = Project.for_account(@aid).find_by_name(pname)
		end
		if tProj.nil? then
			puts i.keys
			p = Hash.new()
			
			p[:active] = true
			p[:name] = pname
			p[:upl_number] = pid
			p[:owner_id] = oid
			p[:description] = desc
			p[:category] = cat
			p[:account_id] = @aid
			p[:fixed_resource_budget] = 5
			p[:rtm] = rtm
			p[:fin_type] = finType
			p[:end_date] = eDate
			p[:psh] = div
			p[:ctpriority] = okr
			p[:initiative_id] = iId
			puts p.to_s
			newproj << p
		else
			puts "Found Existing Project by Id or Name"
			puts "    : " + tProj.name
			u = Hash.new()
			
			if pname != 'undefined' then
				u[:name] = pname
			end
			u[:upl_number] = pid ||= tProj.upl_number
			u[:owner_id] = oid ||= tProj.owner_id
			u[:description] = desc ||= tProj.description
			u[:category] = cat ||= tProj.category
			u[:rtm] = rtm ||= tProj.rtm
			u[:fin_type] = finType ||= tProj.fin_type
			u[:end_date] = eDate ||= tProj.end_date
			u[:psh] = div ||= tProj.psh
			u[:ctpriority] = okr ||= tProj.ctpriority
			u[:initiative_id] = iId ||= tProj.initiative_id
			
			puts "UPDATE HASH VALUE:   "
			puts u.to_s
			unless Project.update(tProj.id,u)
				puts "FAILED UPDATE of EXISTING PROJECT"			
			end
		end
	end	
		
	sval = Project.import(cols,newproj, validate: false)
	puts newproj.to_s
		
	  respond_to do |format|
		  if sval
			format.html { redirect_to projects_path, notice: "Projects Imported" and return }
			format.json { render json: projects_path, status: :imported, location: @projects }
		  else
			format.html { render action: "index" }
			format.json { render json: @projects.errors, status: :unprocessable_entity }
		  end
	  end
  end
  
  # GET /projects/1
  # GET /projects/1.json
  def show
    require 'gchart'
    @project = Project.find(params[:id])

	#Prep Chart Data
	@clabels = []
	@cvalues = []
	@cdata = Assignment.recent(view_context.current_period - 0.10).where('set_period_id <= ? AND project_id = ?',  
		view_context.current_period, params[:id]).group(:set_period_id).sum(:effort).map{|a|[a[0],a[1].to_i]}
# 	puts 'Chart Data'
# 	puts @cdata
	@clabels = @cdata.to_h.keys.map{|e| "week " + view_context.week_from_period(e).to_s}
	@clabels.sort!
	@cvalues = @cdata.to_h.values
# 	puts 'Labels:'
# 	puts @clabels.to_s	
	#Data for systems pie chart
	@cdata = Assignment.where('set_period_id <= ? AND project_id = ? AND tech_sys_id > 0', 
		view_context.current_period, params[:id]).group(:tech_system).sum(:effort).map{|a|[a[0],a[1].to_i]}
	@slabels = @cdata.to_h.keys.map{|e| if !e.nil? then e.name else "TBD" end}
	@svalues = @cdata.to_h.values	
	
	#scope the assignment history per params
     if params[:history_scope] == 'all'
     	@ahistory = @project.assignments.by_org
     else
     	@ahistory = @project.assignments.recent(view_context.current_period - 0.06).by_org
#      	puts "TEST TEST"
#      	puts (view_context.current_period - 0.06).to_s
     end
     
	#End prep chart data
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new
	@ctplist = ctpLists()
	@aid = current_user.primary_account_id
	gon.ctplists = @ctplist
	
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @aid = current_user.primary_account_id
    @ctplist = ctpLists()
    puts @ctplist.to_s
    gon.ctplists = @ctplist
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
	@project.active = true
	
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])
	puts project_params.to_s
    respond_to do |format|
      if @project.update_attributes(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
      	puts @project.errors.to_h.to_s
      	@error = @project.errors.to_h.to_s
        format.html { render action: "edit", alert: 'Update Failed: ' + @error }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /projects/1/archive
  def archive
  	@project = Project.find(params[:id])
  	@project.active = false
  	@project.fixed_resource_budget = 0
  	respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully archived.' }
        format.json { head :no_content }
      else
        format.html { render action: "archive" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end
  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end
  
  #utility to build array of possible ctp picklists for all active themes
  def ctpLists
  	puts "IN CTP UTIL"
  	out = []
  	lasti = -1
  	Initiative.all.each do |i| 
  		puts "processing an init: " + i.id.to_s
  		
  		while((i.id - lasti) > 1) do
  			#fill the gap in idexes in the array
  			out << Setting.for_account(current_user.primary_account_id).for_key(Setting.for_account(current_user.primary_account_id).for_key('p_cust_4').first.value).pluck(:value)
  			lasti += 1
  		end
  		if i.subprilist.present? then
  			out << i.subprilist
  		else
  			out << [""]
  		end
  		lasti += 1
  	end
  	puts out.length
  	puts out.to_s
  	out
  end
  
private
	# Use callbacks to share common setup or constraints between actions.
	def set_project
	  @project = Project.find(params[:id])
	end

	# Only allow a trusted parameter "white list" through.
	def project_params
# 		attr_accessible :owner, :initiative, :active, :description, :category, :name, :owner_id,
#   		:initiative_id, :fixed_resource_budget, :upl_number, :keyproj, :rtm, :psh, :tribe, :ctpriority, :end_date

	  params.require(:project).permit(:owner, :initiative, :active, :description, :category, :name, :owner_id,
  		:initiative_id, :fixed_resource_budget, :upl_number, :keyproj, :rtm, :psh, :tribe, :ctpriority, :account_id, 
  		:end_date, :initiative_id)
	end
end
