class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # rescue_from CanCan::AccessDenied do |exception|
#     redirect_to root_path, :alert => exception.message
#   end
  
  def require_admin
    unless current_user.admin | current_user.isstatususer?
      #flash[:error] = "You must be an admin in to access that section" 
      redirect_to team_user_path(:id => current_user.id) # Prevents the current action from running
    end
  end
  def require_verified
    unless current_user and current_user.verified
      flash[:error] = "Your account has not been validated, contact administrator to access this section" 
      redirect_to new_user_session_path # Prevents the current action from running
    end
  end
  def require_manager
  	unless current_user.ismanager | current_user.admin
  		redirect_to team_user_path(:id => current_user.id)
  	end
  end
  def calc_chart_data(rs,dimKey='p_cust_1')
		#####  Handle .allocate effort categories for YTD #######
		combined = rs.to_h
		key1 = Setting.for_key(dimKey).first.value #the key for settings of type dimKey
		#handle missing keys in passed in data
		Setting.for_key(key1).each do |s|
			
			if !combined.key?(s.value) then
				#add zero so allocation works right
				puts "adding missing key: "
				puts s.key + ":" + s.value
				combined[s.value] = 0
			end
		end
		puts "Hash after adding empty Keys:"
		puts combined
		
		##### V3 Implementation ####
		cCount = combined.count 
		
		allocateTotal = 0
		
		#check if any of the custom-field values for p_cust_2 are tagged wtih the .allocate adornment
		
# 		puts 'Category CF Key is: ' +  key1
		allocateKeys = Setting.for_key(key1).where('value LIKE ?', "%.all%")
		exludeKeys = Setting.for_key(key1).where('value LIKE ?', "%.ex%")
		puts 'Exclude Keys ' + exludeKeys.length.to_s
		cCount = cCount - exludeKeys.length
		if allocateKeys.length > 0 then
			puts "FOUND ALLOCATION Catgory VALUE"
			allocateKeys.each do |k|
				#find hash item that matches the .allocate key
				puts 'PROCESSING - ' + k.displayname
				hentry = combined.assoc(k.value) 
				
				if !hentry.nil? then
					puts '##### ' + hentry.to_s
					allocateTotal += hentry[1]
					cCount = cCount - 1
				end
			end
			puts 'Number of keys to allocate to is ' + cCount.to_s
			puts "##### Amount to Allocate =  " + allocateTotal.to_s
			
			#### Now iterate the non-allocated and non-exluded keys and allocate to them
			update ={}
			combined.map do |k,v|
				if exludeKeys.where("value = ?", k).length == 0 then #if not a .exlude key
					if allocateKeys.where("value = ?", k).length == 0 then #if not a .allocate key
						puts 'ALLOCATE TO ' + k
						v += allocateTotal.to_d/cCount #add equal proportion of allocate amount to this key
						update.store(k,v)
					else
						combined.delete(k) #delete the .alloc key so it doesn't show up
					end
				else
					puts "FOUND EXDCLUDE KEY"
					if v == 0 then
						combined.delete(k) #delete empty keys
					end
				end
			end
			puts 'UPDATE Hash - ' + update.to_s
			if update.length > 0 then
				combined.merge!(update)
			end
		else
			puts "NO ALLOC KEYS FOUND"
		end
		 
		combined.sort_by {|k,v| k.to_s}.to_h
	end
	
  protected

        def configure_permitted_parameters
            devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :manager])
        end
end
