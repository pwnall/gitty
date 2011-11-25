source 'http://rubygems.org'

gem 'rails', '>= 3.1.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git',
#              :branch => '3-0-stable'
gem 'mysql2', '>= 0.3.10'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 3.1.5'
  gem 'coffee-rails', '>= 3.1.1'
  gem 'uglifier'
  
  gem 'therubyracer'
end

gem 'jquery-rails', '>= 1.0.14'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

gem 'authpwn_rails', '>= 0.10.2', :path => '../authpwn_rails'
gem 'configvars_rails', '>= 0.5.1'
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
# group :development, :test do
#   gem 'webrat'
# end
group :test do
  gem 'mocha'
  gem 'thin'
end
