class InviteCode < ApplicationRecord
  belongs_to :account
  
  def self.create_new_code(tacct)
  	rcode = ('a'..'z').to_a.shuffle[0,14].join
  	puts "Generated Invite code: ?", rcode 
  	xcode = InviteCode.new({ :account_id => tacct.id, :code => rcode, :expire => 2.days.from_now})
  	if xcode.save then
  		puts "New Invite Code for " + tacct.name + ": " + rcode
  	else
  		xcode = null
  	end
  	return xcode
  end
  
  scope :current, -> {where('expire > ?', DateTime.now).order('expire')}
  scope :expired, -> {where('expire < ?', DateTime.now).order('expire')}
end
