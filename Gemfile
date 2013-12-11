source 'http://rubygems.org'

gem 'rails', '>= 4.0.2'

gem 'mysql2', '>= 0.3.14'
gem 'sqlite3', '>= 1.3.8'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '>= 4.0.0'
  gem 'coffee-rails', '>= 4.0.1'
  gem 'coffee-script-source', '>= 1.6.3'
  gem 'uglifier', '>= 2.3.2'

  gem 'therubyracer', '>= 0.12.0', require: 'v8'
end

gem 'jquery-rails', '>= 2.2.1'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug'

gem 'authpwn_rails', '>= 0.15.0'
gem 'configvars_rails', '>= 0.6.1'
gem 'gravatar-ultimate', '>= 2.0.0'
gem 'grit', git: 'https://github.com/pwnall/grit.git', branch: 'gitty'
gem 'json', platforms: [:mri_18, :jruby]
gem 'markdpwn', '>= 0.1.7'
gem 'net-ssh', '>= 2.7.0', require: 'net/ssh'
gem 'posix-spawn', '>= 0.3.6'
gem 'rbtree', '>= 0.4.1', platform: :mri
gem 'rbtree-pure', '>= 0.1.1', require: 'rbtree', platforms: [:jruby, :rbx]
gem 'topological_sort', '>= 0.1.1'

# Monitoring.
gem 'oink', '>= 0.10.1'

# Bundler can't do decent dependency resolution.
gem 'rdoc', '~> 3.12'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'railroady', '>= 0.4.5'
  gem 'thin', '>= 1.6.1'
end

group :test do
  gem 'mocha', '>= 0.14.0', require: 'mocha/setup'
end
