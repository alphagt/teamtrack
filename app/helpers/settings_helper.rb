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
			out = Setting.for_key(key).where('value = ?', val).first.displayname || "blank"
		end
		out
	end
end
