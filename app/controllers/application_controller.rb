class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # rescue_from CanCan::AccessDenied do |exception|
#     redirect_to root_path, :alert => exception.message
#   end
  
  def require_admin
    unless current_user.admin
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
end
