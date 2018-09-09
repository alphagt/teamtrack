class Setting < ActiveRecord::Base

	default_scope {order('settings.key')}
	scope :for_key, -> (rStr){where('settings.key = ?', rStr).order('settings.ordinal')}
end
