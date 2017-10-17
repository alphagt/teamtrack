class BpsOrgFix < ActiveRecord::Migration
  def change
  	User.all.each do |u|
  		puts u.name
  		u.org = "BPS"
  		u.save
  	end
  puts "All users fixed"
  end
end
