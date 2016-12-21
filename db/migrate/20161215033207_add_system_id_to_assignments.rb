class AddSystemIdToAssignments < ActiveRecord::Migration
  def change
  	add_column :assignments, :tech_sys_id, :int, :default => 0
  end
end
