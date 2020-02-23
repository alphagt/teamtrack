class ChangePrimaryAdminColumnName < ActiveRecord::Migration[5.1]
  def change
  	rename_column :accounts, :primary_admin, :primary_admin_id
  	rename_column :accounts, :secondary_admin, :secondary_admin_id
  end
end
