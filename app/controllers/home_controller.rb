class HomeController < ApplicationController
  before_action :authenticate_user!
  def index
  	aid = current_user.primary_account_id
  	if aid > 0
		@exId = User.for_account(aid).find_by_name("ExEmployeeMgr").id
		@users = User.for_account(aid).where('manager_id != ?', @exId).order("manager_id,name")
		if !current_user.ismanager && current_user.impersonate_manager.nil? then
			redirect_to projects_path(:org => "0") if current_user and current_user.verified
		else
			if !current_user.ismanager then
				mid = current_user.impersonate_manager
			else
				mid = current_user.id
			end
			redirect_to team_user_path(:id => mid) if current_user and current_user.verified
		end
	end

  end
  
  
end
