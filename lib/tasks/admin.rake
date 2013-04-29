namespace :admin do
  desc "Sets up DNS via dynect API to point to Jenkins server."
  task :create_subdomain, :project, :ip_address do |t, args|
    args.with_defaults(:project => config['project'], :ip_address => config['ip_address'])
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

    client = DynectRest.new(customer, username, password, zone)
    client.a.fqdn(project_fqdn).address(project_ip).save
    client.publish

  end
end
