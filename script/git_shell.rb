#!/usr/bin/env ruby
#
# This is invoked by sshd when the git user logs in.

require 'net/http'
begin
  require 'json'
rescue LoadError
  # Ruby 1.8
  require 'rubygems'
  require 'json'
end

load File.expand_path('../../lib/git_shell_executor.rb', __FILE__)
GitShellExecutor.new.run ARGV
