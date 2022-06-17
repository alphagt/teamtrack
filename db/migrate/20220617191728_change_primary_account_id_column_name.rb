class ChangePrimaryAccountIdColumnName < ActiveRecord::Migration[5.1]
  def change
  	rename_column :settings, :primary_account_id, :account_id
  end
end
