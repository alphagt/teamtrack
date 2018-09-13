class AddDescriptionToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :description, :string
  end
end
