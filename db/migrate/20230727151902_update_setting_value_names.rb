class UpdateSettingValueNames < ActiveRecord::Migration[5.2]
  def self.up
  	Setting.where(key: 'team').update_all(key: 'tribe')
  	Setting.where(key: 'priority').update_all(key: 'ctpriority')
  	Setting.where(key: 'p_cust_6').update_all(value: 'tribe')
  	Setting.where(key: 'p_cust_4').update_all(value: 'ctpriority')
  end
  def self.down
  	Setting.where(key: 'tribe').update_all(key: 'team')
  	Setting.where(key: 'ctpriority').update_all(key: 'priority')
  	Setting.where(key: 'p_cust_6').update_all(value: 'team')
  	Setting.where(key: 'p_cust_4').update_all(value: 'priority')
  end
end
