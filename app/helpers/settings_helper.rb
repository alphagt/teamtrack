module SettingsHelper

	def next_ordinal_for(key)
		out = 1
		if !Setting.find_by_key(key).nil?
			out = Setting.for_key(key).last.ordinal + 1
		end
		out
	end
end
