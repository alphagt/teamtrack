class Setting < ActiveRecord::Base

	default_scope {order('settings.key')}
	scope :for_key, -> (rStr){where('settings.key = ?', rStr).order('settings.ordinal')}
	scope :core_only, -> {where('settings.stype = 0').order('settings.ordinal')}
	scope :non_core, -> {where('settings.stype != 0').order('settings.ordinal')}
end
