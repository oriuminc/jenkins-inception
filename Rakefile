#!/usr/bin/env ruby

require './lib/ext/string'
require 'yaml'

def load_yaml(file)
  if File.exist?(file)
    YAML.load_file(file)
  end
end

task :load_config do
  @config_file = ENV['INCEPTION_CONFIG'] || 'roles/config.yml'
  @config = load_yaml(@config_file) || {}
end

Dir.glob('lib/tasks/*.rake').each { |r| import r }
