class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :email
      t.integer :primary_admin
      t.integer :secondary_admin
      t.boolean :active
      t.date :termdate
      t.integer :userquota

      t.timestamps
    end
  end
end
