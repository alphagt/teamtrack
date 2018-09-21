class AddDefaultValueToTribe < ActiveRecord::Migration
   def up
  	change_column :projects, :tribe, :string, default: "NA"
  end
  def down
  	change_column :projects, :tribe, :string, default: nil
  end
end
