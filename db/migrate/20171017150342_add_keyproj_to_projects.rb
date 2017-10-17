class AddKeyprojToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :keyproj, :boolean
  end
end
