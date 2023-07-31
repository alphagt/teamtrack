class AddFinTypeToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :fin_type, :string, default: "Undefined"
  end
end
