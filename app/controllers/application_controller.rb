class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # rescue_from CanCan::AccessDenied do |exception|
#     redirect_to root_path, :alert => exception.message
#   end
  
  def require_admin
    unless current_user.admin
      #flash[:error] = "You must be logged in to access this section" 
      redirect_to team_user_path(:id => current_user.id) # Prevents the current action from running
    end
  end
end
