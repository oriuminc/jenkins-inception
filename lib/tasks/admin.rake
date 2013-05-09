namespace :admin do
  desc "Create a Rackspace server if it doesn't already exist.

  The configuration of the created server will be:
    - 512MB RAM
    - Ubuntu Lucid 10.04

  Requires the following envvars to be set:
    - RACKSPACE_USERNAME
    - RACKSPACE_API_KEY"
  task :create_server, :project do |t, args|
    Rake::Task["load_config"].invoke
    args.with_defaults(:project => @config['project'])

    # Ensure envvars set
    required_envvars = [
      'RACKSPACE_USERNAME',
      'RACKSPACE_API_KEY',
    ]
    required_envvars.each do |envvar|
      raise "The following environment variables must be set: #{required_envvars.join(', ')}" if ENV[envvar].nil?
    end

    system "bundle exec knife rackspace server create --server-name=#{args.project}-ci"

    # Load knife.rb
    require 'chef/knife'
    Chef::Knife.new.configure_chef
    knife_config = Chef::Config.knife

    # Get servers
    require 'fog'
    connection = Fog::Compute.new({
      :provider           => 'Rackspace',
      :rackspace_username => knife_config[:rackspace_username],
      :rackspace_api_key  => knife_config[:rackspace_api_key],
      :rackspace_endpoint => knife_config[:rackspace_endpoint],
      :version            => knife_config[:rackspace_version],
    })
    servers = connection.servers

    # Get data for our server (the last one created)
    servers = servers.sort_by { |k| k.created }
    latest_server = servers[-1]

    puts "Writing IP address of new server '#{args.project}' to config file."
    @config['ip_address'] = latest_server.ipv4_address
    File.open(@config_file, 'w') do |out|
      YAML::dump(@config, out)
    end
  end

  desc "Sets up DNS via dynect API to point to Jenkins server."
  task :create_subdomain, :project, :ip_address do |t, args|
    Rake::Task["load_config"].invoke
    args.with_defaults(:project => @config['project'], :ip_address => @config['ip_address'])
    require 'dynect_rest'

    # Ensure envvars set
    required_envvars = [
      'INCEPTION_DYNECT_CUSTOMER',
      'INCEPTION_DYNECT_USERNAME',
      'INCEPTION_DYNECT_PASSWORD',
      'INCEPTION_DYNECT_ZONE',
    ]
    required_envvars.each do |envvar|
      raise "The following environment variables must be set: #{required_envvars.join(', ')}" if ENV[envvar].nil?
    end

    customer = ENV['INCEPTION_DYNECT_CUSTOMER']
    username = ENV['INCEPTION_DYNECT_USERNAME']
    password = ENV['INCEPTION_DYNECT_PASSWORD']
    zone = ENV['INCEPTION_DYNECT_ZONE']

    project_fqdn = "ci.#{args.project}.#{zone}"
    project_ip = args.ip_address

    puts "Creating DNS A-record..."
    client = DynectRest.new(customer, username, password, zone)
    client.a.fqdn(project_fqdn).address(project_ip).save
    client.publish
    puts "Successfully created DNS A-record pointing #{project_fqdn} to #{project_ip}!"

  end
end
