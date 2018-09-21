class AddDefaultValueToCtpriority < ActiveRecord::Migration
  def up
  	change_column :projects, :ctpriority, :string, default: "NA"
  end
  def down
  	change_column :projects, :ctpriority, :string, default: nil
  end
end
