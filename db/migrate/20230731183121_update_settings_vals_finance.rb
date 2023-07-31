class UpdateSettingsValsFinance < ActiveRecord::Migration[5.2]
 def self.up
  	Setting.where(key: 'p_cust_6').update_all(value: 'fin_type')
  	Setting.where(key: 'tribe').update_all(key: 'fin_type')
  end
  def self.down
  	Setting.where(key: 'p_cust_6').update_all(value: 'tribe')
  	Setting.where(key: 'fin_type').update_all(key: 'tribe')
  end
end
