class AddSubmgrsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :submgrs, :string
  end
end
