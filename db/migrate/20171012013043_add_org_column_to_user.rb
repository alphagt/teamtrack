class AddOrgColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :org, :string
  end
end
