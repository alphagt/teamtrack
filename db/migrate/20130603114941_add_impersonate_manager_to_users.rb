class AddImpersonateManagerToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :impersonate_manager, :integer, :default => 0
  end
end
