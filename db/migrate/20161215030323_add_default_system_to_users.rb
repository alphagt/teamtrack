class AddDefaultSystemToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :default_system_id, :integer
  end
end
