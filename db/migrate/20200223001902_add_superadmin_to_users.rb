class AddSuperadminToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :superadmin, :boolean, :default => false
  end
end
