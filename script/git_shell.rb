#!/usr/bin/env ruby
#
# This is invoked by sshd when the git user logs in.

require 'net/http'

begin
  require 'net/https'
rescue LoadError
  # Ruby 1.8 without OpenSSL support built in.
end

begin
  unless defined? JSON
    require 'json'
  end
rescue LoadError
  # Ruby 1.8
  begin
    require 'rubygems'
    require 'json'
  rescue LoadError
    # If the JSON gem is not available, use a hack that mostly works.
    module JSON
      def self.parse(data)
        unless data[0] == ?{ && data[-1] == ?}
          raise JSON::JSONError, 'Not JSON'
        end
        eval data.gsub(/([^\\])":/, '\\1"=>')
      end
    end
    unless defined? JSON::JSONError
      JSON::JSONError = SyntaxError
    end
  end
end

load File.expand_path('../../lib/git_shell_executor.rb', __FILE__)
GitShellExecutor.new.run ARGV
