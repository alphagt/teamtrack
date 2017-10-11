class ChangeColumnDefault < ActiveRecord::Migration
  def up
	change_column :initiatives, :active, :boolean, :default => true
  end
end
