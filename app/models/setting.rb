class Setting < ApplicationRecord
	validate :protected_settings, :on => [:destroy, :delete]

	default_scope {order('settings.key')}
	scope :for_key, -> (rStr){where('settings.key = ?', rStr).order('settings.ordinal')}
	scope :core_only, -> {where('settings.stype = 0').order('settings.ordinal')}
	scope :non_core, -> {where('settings.stype != 0').order('settings.ordinal')}
	scope :for_account, -> (aid){where('settings.account_id = ?', aid)}


	def protected_settings
		errors.add("Failed to update setting:  Protected System Setting!") if key == 'category' && value == 'OVH.allocate'
	end
	
end
