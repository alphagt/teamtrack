class AddNoteToInviteCodes < ActiveRecord::Migration[5.1]
  def change
    add_column :invite_codes, :note, :string
  end
end
