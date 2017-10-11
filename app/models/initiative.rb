class Initiative < ActiveRecord::Base
has_many :projects

scope :active, -> {where('active = true')}
scope :current_year, -> {where('fiscal = 2017')}
end
