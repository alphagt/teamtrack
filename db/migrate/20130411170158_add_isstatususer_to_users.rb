class AddIsstatususerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :isstatususer, :boolean, :default => false 
  end
end
