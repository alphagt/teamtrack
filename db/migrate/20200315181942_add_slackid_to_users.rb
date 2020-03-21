class AddSlackidToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :slackid, :string
  end
end
