module SettingsHelper

	def next_ordinal_for(key, aid = -1)
		out = 1
		if aid == -1 
			aid = current_user.primary_account_id
		end
		if !Setting.for_account(aid).find_by_key(key).nil?
			out = Setting.for_account(aid).for_key(key).last.ordinal || 0
			out += 1
		end
		out
	end
	
	def display_name_for(key, val, aid = -1)
		out = 'Undefined'
# 		puts "setting Helper Inputs:"
# 		puts key
# 		puts val
# 		puts aid
		
		if aid == -1
			aid = current_user.primary_account_id
		end
		#special handling, back-compat for fy offset as sys_name key
		if val == "fy offset" && Setting.for_account(aid).for_key(key).where('value = ?', val).empty? then
			puts "Switch to new fy offset key"
			out = Setting.for_account(aid).find_by_key(val).value
		else
			if !Setting.for_account(aid).find_by_key(key).nil?
				s = Setting.for_account(aid).for_key(key).where('value LIKE ?', val + "%")
				if s.length > 0
					out = s.first.displayname || "blank"
				else
					#handle legacy situation where stored 'val' is actually the displayname
					if Setting.for_account(aid).for_key(key).where('displayname = ?', val).length > 0
						#val is the displayname
						out = val
					end
				end
			end
		end
		out
	end
end
