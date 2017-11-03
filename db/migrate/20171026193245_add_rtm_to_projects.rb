class AddRtmToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :rtm, :string
  end
end
