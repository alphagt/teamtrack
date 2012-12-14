class CreateSetPeriods < ActiveRecord::Migration
  def change
    create_table :set_periods do |t|
      t.integer :fiscal_year
      t.integer :week_number
      t.integer :cweek_offset

      t.timestamps
    end
  end
end
