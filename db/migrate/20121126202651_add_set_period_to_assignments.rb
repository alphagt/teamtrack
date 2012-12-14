class AddSetPeriodToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :set_period_id, :integer
    remove_column :assignments, :fiscal_year
    remove_column :assignments, :week
  end
end
