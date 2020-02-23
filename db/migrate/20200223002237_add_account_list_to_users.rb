class AddAccountListToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :account_list, :text
  end
end
