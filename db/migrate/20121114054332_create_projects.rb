class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :active
      t.integer :owner_id
      t.string :description

      t.timestamps
    end
  end
end
