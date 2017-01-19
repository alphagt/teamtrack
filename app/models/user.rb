class User < ActiveRecord::Base
  has_many :subordinates, :class_name => "User", :foreign_key => "manager_id"
  belongs_to  :default_system, :class_name => "TechSystem", :foreign_key => "default_system_id"
  belongs_to :manager, :class_name => "User", :touch => true
  belongs_to :impersonates, :class_name => "User", :foreign_key => "impersonate_manager"
  has_many :assignments
  has_many :projects, :through => :assignments
  has_many :tech_systems, :through => :assignments
  
  validate :unique_name, :on => :create
  #default_scope {order("manager_id,name")}
  
  scope :ordered_by_manager, -> {joins('INNER Join users as mgrs on mgrs.id = users.manager_id or users.id = 1')
  	.distinct.order('mgrs.name').order('users.name')}

  
  scope :ordered_by_name, -> {order('users.name')}
  
  scope :managers_only, -> {where('ismanager = true').order('users.name')}

  
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable :registerable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :admin, :password_confirmation, :remember_me 
  attr_accessible :default_system, :default_system_id, :verified, :isstatususer
  attr_accessible :ismanager, :impersonates, :impersonate_manager, :manager, :manager_id
  # def initialize(user)
# 
# 	  user ||= User.new # guest user (not logged in)
# 	  if !user.admin?
# 		devise :registerable
# 	  end
#   end
#   
  def self.create_new_user(name, email, manager_id, pwd )
    puts 'IN MODEL'
    xuser = User.new({ :email => email, :password => "abc123", :password_confirmation => "abc123", :name => name, :manager_id => manager_id })
   	pFail = xuser.save
   	puts xuser.name
   	return xuser
  end
  
  def unique_name
  	dupCount = User.where(:name => name).count
  	puts dupCount
  	errors.add(:notice, "User already exists!") unless
  	dupCount == 0
  end	
end
