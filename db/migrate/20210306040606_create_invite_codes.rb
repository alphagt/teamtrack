class CreateInviteCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :invite_codes do |t|
      t.references :account, foreign_key: true
      t.string :code
      t.datetime :expire

      t.timestamps
    end
  end
end
