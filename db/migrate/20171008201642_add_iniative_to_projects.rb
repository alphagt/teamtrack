class AddIniativeToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :initiative, index: true, foreign_key: true
  end
end
