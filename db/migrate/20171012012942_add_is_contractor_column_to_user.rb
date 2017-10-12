class AddIsContractorColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_contractor, :boolean
  end
end
