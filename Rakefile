#!/usr/bin/env ruby

task :load_config do
  require 'yaml'

  require './lib/ext/string'

  def load_yaml(file)
    if File.exist?(file)
      YAML.load_file(file)
    end
  end

  @config_file = ENV['INCEPTION_CONFIG'] || 'roles/config.yml'
  @config = load_yaml(@config_file) || {}
end

Dir.glob('lib/tasks/*.rake').each { |r| import r }
