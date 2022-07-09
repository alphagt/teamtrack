class AddAccountIndexToProjects < ActiveRecord::Migration[5.1]
  def change
  	remove_index :projects, :upl_number
    add_index :projects, [:account_id,:upl_number], unique: true
  end
end
