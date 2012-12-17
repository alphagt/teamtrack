class HomeController < ApplicationController
  def index
  	@users = User.all
  	redirect_to team_user_path(:id => current_user.id)
  end
end
