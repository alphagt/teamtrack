class AddAccountIdToTechSystems < ActiveRecord::Migration[5.1]
  def change
    add_column :tech_systems, :account_id, :integer, :defalut => 0
     add_index :tech_systems, :account_id, unique: false
  end
end
