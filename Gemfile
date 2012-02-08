source 'http://rubygems.org'

gem 'rails', '>= 3.2.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git',
#              :branch => '3-0-stable'
gem 'mysql2', '>= 0.3.11'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 3.2.3'
  gem 'coffee-rails', '>= 3.2.1'
  gem 'uglifier'
  
  gem 'therubyracer', '>= 0.9.9'
end

gem 'jquery-rails', '>= 2.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

gem 'authpwn_rails', '>= 0.10.9'
gem 'configvars_rails', '>= 0.5.2'
gem 'gravtastic', :git => 'git://github.com/pwnall/gravtastic.git',
                  :ref => '4a98c9784fb096352f5d8f9e333fb94b10fdeb18'
gem 'grit', :git => 'git://github.com/pwnall/grit.git', :branch => 'hunks'
gem 'json', :platforms => [:mri_18, :jruby]
gem 'net-ssh', :require => 'net/ssh'
gem 'rbtree', :platform => :mri
gem 'rbtree-pure', :require => 'rbtree', :platforms => [:jruby, :rbx]
gem 'topological_sort'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'thin'
end

group :test do
  gem 'mocha'
end
