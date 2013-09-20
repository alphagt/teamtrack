class AddIndexes < ActiveRecord::Migration
  def up
  	add_index :users, :manager_id
  	add_index :users, :is_manager
  	add_index :projects, :category
  	add_index :assignments, :user_id
  	add_index :assignments, :project_id
  	add_index :assignments, :set_period_id
  end

  def down
  	remove_index :users, :manager_id
  	remove_index :users, :is_manager
  	remove_index :projects, :category
	remove_index :assignments, :user_id
  	remove_index :assignments, :project_id
  	remove_index :assignments, :set_period_id
  end
end
