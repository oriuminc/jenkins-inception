#!/usr/bin/env ruby

require 'fog/rackspace'

# knife-rackspace
knife[:rackspace_endpoint] = Fog::Compute::RackspaceV2::ORD_ENDPOINT
knife[:rackspace_api_key] = ENV['RACKSPACE_API_KEY']
knife[:rackspace_username] = ENV['RACKSPACE_USERNAME']
knife[:rackspace_version] = 'v2'
knife[:template_file] = '/dev/null'
knife[:flavor] = 2 # 512MB
knife[:image] = 'd531a2dd-7ae9-4407-bb5a-e5ea03303d98' # Ubuntu 10.04 LTS

# knife-solo
knife[:omnibus_version] = '10.26.0'

data_bag_path "data_bags"
cookbook_path [ "cookbooks", "cookbooks-override" ]
role_path "roles"
