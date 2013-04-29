#!/usr/bin/env ruby

require 'yaml'

require './lib/ext/string'

def load_yaml(file)
  if File.exist?(file)
    YAML.load_file(file)
  end
end

config_file = ENV['INCEPTION_CONFIG'] || 'roles/config.yml'
config = load_yaml(config_file) || {}

Dir.glob('lib/tasks/*.rake').each { |r| import r }
