class CreateInitiatives < ActiveRecord::Migration
  def change
    create_table :initiatives do |t|
      t.integer :fiscal
      t.string :name
      t.string :description
      t.boolean :active

      t.timestamps null: false
    end
  end
end
