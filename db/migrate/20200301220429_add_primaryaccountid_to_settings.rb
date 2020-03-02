class AddPrimaryaccountidToSettings < ActiveRecord::Migration[5.1]
  def change
    add_column :settings, :primary_account_id, :integer
  end
end
