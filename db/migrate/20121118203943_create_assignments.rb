class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.boolean :is_fixed
      t.integer :fiscal_year
      t.integer :week
      t.float :effort
      t.integer :user_id
      t.integer :project_id

      t.timestamps
    end
  end
end
