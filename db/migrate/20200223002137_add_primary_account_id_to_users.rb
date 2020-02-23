class AddPrimaryAccountIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :primary_account_id, :integer, :default => 0
  end
end
