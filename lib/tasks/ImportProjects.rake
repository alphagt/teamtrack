
desc "import csv file"
task :import_projects => :environment do
    filename = File.expand_path("./assets/jira.csv")	

    options = {:strip_chars_from_headers => "s/([()])//g", :key_mapping => {:issue_key => :issue_key, :summary => :summary, :reporter => :owner}, :remove_unmapped_keys => true}
    newproj = []
    cols = [:active, :name, :upl_number, :owner_id, :description]
    SmarterCSV.process(filename, options).each do |r|
		i = r.to_h
		pid = i[:issue_key].split("-")[1].to_i || -1
		puts pid.to_s
		if Project.find_by_upl_number(pid).nil? then
			puts i.keys
			p = Hash.new()
			oUser = User.for_email(i[:owner])
			if oUser.respond_to?(:id) then
				if oUser.ismanager
					oid = oUser.id
				else
					oid = oUser.manager_id
				end
			else
				oid = 1
			end
			p[:active] = true
			p[:name] = i[:issue_key]
			p[:upl_number] = pid
			p[:owner_id] = oid
			p[:description] = i[:summary]
			puts p.to_s
			newproj << p
		end
	end
	puts newproj.to_s
	Project.import(cols,newproj, validate: false)
end

