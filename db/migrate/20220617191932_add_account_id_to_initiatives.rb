class AddAccountIdToInitiatives < ActiveRecord::Migration[5.1]
  def change
    add_column :initiatives, :account_id, :integer, :default => 0
    add_index :initiatives, :account_id, unique: false
  end
end
