class AddMoreIndexes < ActiveRecord::Migration
  def change
  	add_index :users, :org
  	add_index :projects, :name
  	add_index :projects, :active
  	add_index :initiatives, :active
  end
end
