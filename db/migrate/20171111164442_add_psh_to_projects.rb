class AddPshToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :psh, :string
  end
end
