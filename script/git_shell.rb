#!/usr/bin/env ruby
#
# This is invoked by sshd when the git user logs in.

require 'net/http'
require 'rubygems'
require 'json'

load File.expand_path('../../lib/git_shell_executor.rb', __FILE__)
GitShellExecutor.new.run ARGV
