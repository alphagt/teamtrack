class AddFixedResourceBudgetToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :fixed_resource_budget, :integer
  end
end
