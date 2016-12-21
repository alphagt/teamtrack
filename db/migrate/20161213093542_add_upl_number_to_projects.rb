class AddUplNumberToProjects < ActiveRecord::Migration
  def change
  	add_column :projects, :upl_number, :int, :default => 0
  end
end
