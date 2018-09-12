class AddTagToInitiatives < ActiveRecord::Migration
  def change
    add_column :initiatives, :tag, :string
  end
end
