class UpdateInitIdOnProjects < ActiveRecord::Migration[5.2]
  def change
  	Project.all.each do |p|
  		Assignment.for_project(p.id).update_all(initiative_id: p.initiative_id)
  	end
  end
end
