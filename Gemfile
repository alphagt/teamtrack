source 'https://rubygems.org'
ruby "2.4.5"

gem 'rails', '~> 5.1.0'



# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


#gem 'sqlite3', :group => [:development, :test]
#group :production do
#  gem 'thin'
#  gem 'pg'
#end

gem 'mysql2', '~> 0.4.0', :group => [:development, :test, :production]
group :production do
  gem 'rails_12factor'
end

#Gems to support providing rest API
gem 'grape'
gem 'rack-cors', :require => 'rack/cors'
gem 'slack-ruby-client' 

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 5.0.6'
  gem 'coffee-rails', '~> 4.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

gem 'devise'

gem 'simple_form', '~> 5.0.0'

gem 'cancan'

gem 'gon'

gem 'smarter_csv'
gem 'activerecord-import'

gem 'bootstrap-sass', '~> 3.2.0'
gem 'bootstrap-datepicker-rails'
gem 'autoprefixer-rails'
gem 'googlecharts'

#Excel Export Gem
gem 'axlsx_rails'

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

gem 'derailed_benchmarks', group: :development
gem 'stackprof', group: :development

#Slack Integration
gem 'slack-ruby-client'


#backward compat for attribute protection in Rails 4
#gem 'protected_attributes'
