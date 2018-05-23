class AddTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :etype, :string
  end
end
