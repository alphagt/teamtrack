class HomeController < ApplicationController
  def index
  	@users = User.all
  	redirect_to team_user_path(:id => current_user.id) if current_user and current_user.verified
  end
end
