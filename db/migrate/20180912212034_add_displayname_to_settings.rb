class AddDisplaynameToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :displayname, :string
  end
end
