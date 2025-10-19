source 'https://rubygems.org'
ruby "3.4.7"

gem 'rails', '~> 7.2.2'



# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


#gem 'sqlite3', :group => [:development, :test]
#group :production do
#  gem 'thin'
#  gem 'pg'
#end

gem 'mysql2', '~> 0.5.0', :group => [:development, :test, :production]
group :production do
  gem 'rails_12factor'
end

#Gems to support providing rest API
gem 'grape'
gem 'rack-cors', :require => 'rack/cors'
gem 'slack-ruby-client' 
gem 'httparty'
gem 'sucker_punch', '~> 2.0'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  #gem 'sass-rails', require: false
  gem 'sassc-rails'
  gem 'coffee-rails', '~> 4.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby
	gem 'mini_racer'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'bigdecimal', '~> 3.1.8'

gem 'devise'

gem 'simple_form', '~> 5.0.0'

gem 'cancan'

gem 'gon'

gem 'smarter_csv'
gem 'activerecord-import'

gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails'
gem 'autoprefixer-rails'
gem 'googlecharts'
gem 'select2-rails'


#Excel Export Gem
gem 'caxlsx_rails'

#chart helper
gem 'chartkick'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'

gem 'benchmark', group: :development
gem 'derailed_benchmarks', group: :development
gem 'stackprof', group: :development


#backward compatin Rails 6

gem 'puma', '~> 7.1'
gem 'concurrent-ruby', '~> 1.1'

