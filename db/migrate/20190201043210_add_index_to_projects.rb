class AddIndexToProjects < ActiveRecord::Migration
  def change
    add_index :projects, :upl_number, unique: true
  end
end
