class ChangeAssignmentsSetPeriodIdType < ActiveRecord::Migration
  def change
  		change_column :assignments, :set_period_id, :decimal, :precision => 6, :scale => 2
  		change_column :assignments, :effort, :decimal, :precision => 2, :scale => 1
  end
end
