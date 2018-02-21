class AddOrgownerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :orgowner, :boolean
  end
end
