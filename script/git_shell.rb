#!/usr/bin/env ruby
#
# This is invoked by sshd when the git user logs in.

require 'net/http'
begin
  require 'json'
rescue LoadError
  # Ruby 1.8
  begin
    require 'rubygems'
    require 'json'
  rescue LoadError
    # If the JSON gem is not available, use a hack that mostly works.
    module JSON
      def self.parse(data)
        eval data.gsub('":', '"=>')
      end
    end
    JSON::JSONError = SyntaxError
  end
end

load File.expand_path('../../lib/git_shell_executor.rb', __FILE__)
GitShellExecutor.new.run ARGV
