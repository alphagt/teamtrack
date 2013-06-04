class AddCategoryToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :category, :string, :default => 'Unassigned'
  end
end
