class AddCtpriorityToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :ctpriority, :string
  end
end
