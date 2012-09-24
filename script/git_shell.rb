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
    # If the JSON gem is not available, use the built-in yaml parser.
    # Little-known fact: JSON is a subset of YAML.
    require 'yaml'
    module JSON
      def self.parse(data)
        YAML.load data
      end
    end
    if defined? YAML::ParserError
      JSON::JSONError = YAML::ParserError
    elsif defined? YAML::SyntaxError
      JSON::JSONError = YAML::SyntaxError
    else
      JSON::JSONError = RuntimeError
    end
  end
end

load File.expand_path('../../lib/git_shell_executor.rb', __FILE__)
GitShellExecutor.new.run ARGV
