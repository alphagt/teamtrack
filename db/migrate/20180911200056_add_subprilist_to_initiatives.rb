class AddSubprilistToInitiatives < ActiveRecord::Migration
  def change
    add_column :initiatives, :subprilist, :string
  end
end
