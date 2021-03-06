module SettingsHelper

	def next_ordinal_for(key)
		out = 1
		if !Setting.find_by_key(key).nil?
			out = Setting.for_key(key).last.ordinal || 0
			out += 1
		end
		out
	end
	
	def display_name_for(key, val)
		out = 'Undefined'

			if !Setting.find_by_key(key).nil?
				s = Setting.for_key(key).where('value = ?', val)
				if s.length > 0
					out = s.first.displayname || "blank"
				else
					#handle legacy situation where stored 'val' is actually the displayname
					if Setting.for_key(key).where('displayname = ?', val).length > 0
						#val is the displayname
						out = val
					end
				end
			end
		out
	end
end
