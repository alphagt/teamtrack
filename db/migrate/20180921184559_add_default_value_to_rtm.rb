class AddDefaultValueToRtm < ActiveRecord::Migration
  def up
  	change_column :projects, :rtm, :string, default: "NA"
  end
  def down
  	change_column :projects, :rtm, :string, default: nil
  end
end
