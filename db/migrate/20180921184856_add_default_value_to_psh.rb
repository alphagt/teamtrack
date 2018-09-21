class AddDefaultValueToPsh < ActiveRecord::Migration
  def up
  	change_column :projects, :psh, :string, default: "NA"
  end
  def down
  	change_column :projects, :psh, :string, default: nil
  end
end
