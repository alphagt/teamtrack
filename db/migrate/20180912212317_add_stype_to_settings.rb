class AddStypeToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :stype, :integer
  end
end
