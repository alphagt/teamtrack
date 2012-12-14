class ChangeManagerToIsManager < ActiveRecord::Migration
  def up
  	change_table :users do |t|
  		t.rename :manager, :ismanager
  	end
  end

  def down
  end
end
