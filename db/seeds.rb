case Rails.env
when "development"
#Default User
puts 'SETTING UP DEFAULT USER LOGIN'
user = User.create! :name => 'Ken Toole', :email => 'ktoole@adobe.com', :admin => true, :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
puts 'New user created: ' << user.name
user = User.create! :name => 'Test User', :email => 'test@adobe.com', :verified => true, :password => 'A3kavazz', :password_confirmation => 'A3kavazz'
user['manager_id'] = 1
puts 'New user created: ' << user.name
end

puts 'ADDING DATE INFO 2013'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '1', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '2', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '3', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '4', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '5', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '6', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '7', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '8', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '9', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '10', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '11', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '12', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '13', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '14', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '15', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '16', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '17', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '18', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '19', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '20', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '21', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '22', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '23', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '24', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '25', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '26', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '27', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '28', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '29', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '30', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '31', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '32', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '33', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '34', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '35', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '36', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '37', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '38', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '39', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '40', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '41', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '42', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '43', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '44', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '45', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '46', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '47', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '48', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '49', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '50', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '51', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '52', :cweek_offset => '4'
puts 'ADDING DATE INFO 2014'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '1', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '2', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '3', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '4', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '5', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '6', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '7', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '8', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '9', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '10', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '11', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '12', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '13', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '14', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '15', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '16', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '17', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '18', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '19', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '20', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '21', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '22', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '23', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '24', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '25', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '26', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '27', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '28', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '29', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '30', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '31', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '32', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '33', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '34', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '35', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2013', :week_number => '36', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '37', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '38', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '39', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '40', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '41', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '42', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '43', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '44', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '45', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '46', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '47', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '48', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '49', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '50', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '51', :cweek_offset => '4'
speriod = SetPeriod.create! :fiscal_year => '2014', :week_number => '52', :cweek_offset => '4'

puts 'END DATE PERIOD SETUP'






