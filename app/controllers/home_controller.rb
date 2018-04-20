class HomeController < ApplicationController
  before_filter :authenticate_user!
  def index
  	@exId = User.find_by_name("ExEmployeeMgr").id
  	@users = User.where('manager_id != ?', @exId).order("manager_id,name")
  	if !current_user.ismanager then
  		redirect_to projects_path(:org => "0") if current_user and current_user.verified
  	else
  		redirect_to team_user_path(:id => current_user.id) if current_user and current_user.verified
  	end
  end
end
