class AddIndexToTechSystems < ActiveRecord::Migration
  def change
    add_index :tech_systems, :qos_group
    add_index :tech_systems, :owner_id
  end
end
