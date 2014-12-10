class HomeController < ApplicationController
  def index
  	@exId = User.find_by_name("ExEmployeeMgr").id
  	@users = User.where('manager_id != ?', @exId).order("manager_id,name")
  	redirect_to team_user_path(:id => current_user.id) if current_user and current_user.verified
  end
end
