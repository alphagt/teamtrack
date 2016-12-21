class CreateTechSystems < ActiveRecord::Migration
  def change
    create_table :tech_systems do |t|
      t.string :name
      t.string :description
      t.string :qos_group
      t.integer :owner_id

      t.timestamps null: false
    end
  end
end
