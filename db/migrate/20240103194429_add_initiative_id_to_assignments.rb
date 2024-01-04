class AddInitiativeIdToAssignments < ActiveRecord::Migration[5.2]
  def change
  	add_column :assignments, :initiative_id, :integer, :default => 0
  end
end
