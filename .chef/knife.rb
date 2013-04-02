#!/usr/bin/env ruby

knife[:rackspace_api_key] = ENV['RACKSPACE_API_KEY']
knife[:rackspace_username] = ENV['RACKSPACE_USERNAME']
knife[:rackspace_version] = 'v2'

require 'fog/rackspace/compute_v2'
knife[:rackspace_endpoint] = Fog::Compute::RackspaceV2::ORD_ENDPOINT

knife[:solo] = true
knife[:solo_path] = '~/chef-solo'
knife[:template_file] = '/dev/null'
knife[:flavor] = 2 # 512MB
knife[:image] = 'd531a2dd-7ae9-4407-bb5a-e5ea03303d98' # Ubuntu 10.04 LTS
