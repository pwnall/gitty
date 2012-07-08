source 'http://rubygems.org'

gem 'rails', '>= 3.2.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git',
#              :branch => '3-0-stable'
gem 'mysql2', '>= 0.3.11'
gem 'sqlite3', '>= 1.3.6'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 3.2.5'
  gem 'coffee-rails', '>= 3.2.2'
  gem 'uglifier', '>= 1.2.6'
  
  gem 'therubyracer', '>= 0.10.1'
end

gem 'jquery-rails', '>= 2.0.2'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

gem 'authpwn_rails', '>= 0.11.1'
gem 'configvars_rails', '>= 0.5.2'
gem 'gravatar-ultimate', '>= 1.0.3'
gem 'grit', :git => 'https://github.com/pwnall/grit.git', :branch => 'hunks'
gem 'json', :platforms => [:mri_18, :jruby]
gem 'markdpwn', '>= 0.1.2'
gem 'net-ssh', '>= 2.3.0', :require => 'net/ssh'
gem 'posix-spawn', '>= 0.3.6'
gem 'rbtree', '>= 0.3.0', :platform => :mri
gem 'rbtree-pure', '>= 0.1.1', :require => 'rbtree',
                               :platforms => [:jruby, :rbx]
gem 'topological_sort', '>= 0.1.1'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'railroady', '>= 0.4.5'
  gem 'thin', '>= 1.4.1'
end

group :test do
  gem 'mocha', '>= 0.12.0'
end
