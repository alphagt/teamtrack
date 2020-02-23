class AddDefaultValueToActive < ActiveRecord::Migration[5.1]
  def change
  	change_column_default :accounts, :active, true
  end
end
