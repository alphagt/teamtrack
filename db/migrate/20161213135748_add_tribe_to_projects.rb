class AddTribeToProjects < ActiveRecord::Migration
  def change
  	add_column :projects, :tribe, :string
  end
end
