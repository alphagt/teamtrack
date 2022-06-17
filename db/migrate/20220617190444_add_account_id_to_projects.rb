class AddAccountIdToProjects < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :account_id, :integer, :default => 0
    add_index :projects, :account_id, unique: false
  end
end
