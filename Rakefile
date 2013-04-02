require 'vagrant'
require 'yaml'

class String
  # Strip leading whitespace from each line that is the same as the
  # amount of whitespace on the first line of the string
  # Leaves _additional_ indentation on later lines intact
  # SEE: http://stackoverflow.com/a/5638187/504018
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end
end

def load_yaml(file)
  if File.exist?(file)
    YAML.load_file(file)
  end
end

conf = load_yaml('roles/config.yml') || {}

desc "Generate users from team in GitHub organization.

Requires *one* of two things for authentication:
  - GITHUB_PASSWORD envvar set for your GitHub user, or
  - 'hub' gem installed and configured for use: `brew install hub`"
task :generate_users, :github_org  do |t, args|

  require 'octokit'

  github_org = args.github_org
  github_user = `git config github.user`.chomp
  github_password = ENV['GITHUB_PASSWORD']

  # Authenticate GitHub client somehow
  hub_config_file = File.expand_path('~/.config/hub')
  if !github_password.nil?
    # Authenticate client if password envvar available
    @client = Octokit::Client.new(:login => github_user, :password => github_password)
  elsif File.exists?(hub_config_file)
    # Authenticate with token if not password given and hub gem config file available.
    hub_data = YAML.load_file(hub_config_file)
    github_token = hub_data['github.com'][0]['oauth_token']
    @client = Octokit::Client.new(:login => github_user, :oauth_token => github_token)
  else
    raise "Sorry, this task requires either you set the environment variable GITHUB_PASSWORD, or that you're using the 'hub' gem."
  end

  # Get a listing of teams for GitHub organization and present to user.
  all_teams_data = @client.organization_teams(github_org)

  require 'highline/import'
  selected_team_index = ''
  choose do |menu|
    menu.prompt = "We will use one of the above #{github_org} GitHub teams to generate the appropriate user files.\n"
    menu.prompt << "Please enter the number corresponding to a team:  "

    team_names = all_teams_data.collect { |team| team['name'] }
    menu.choices(*team_names) do |choice|
      say "Generating files for team '#{choice}'..." 
      selected_team_index = team_names.index(choice)
    end
  end

  selected_team_data = all_teams_data[selected_team_index]

  # Get team members and generate username.json files for each.
  team_members_data = @client.team_members(selected_team_data['id'])
  team_members_data.each do |team_member|

    # Generate json user file
    user_file_path = "data_bags/users/#{team_member['login']}.json"
    unless File.exists?(user_file_path)
      user_data = @client.user(team_member['login'])
      # This call doesn't exist yet, so calling manually.
      user_key_data = Octokit.get("users/#{user_data['login']}/keys", {}).first

      file = File.open(user_file_path, "w")
      file.puts <<-EOF.unindent
        {
          "id": "#{user_data['login']}",
          "comment": "#{user_data['name']}",
          "shell": "/bin/zsh",
          "ssh_keys": [
            "#{user_key_data['key']}"
          ]
        }
      EOF
      file.close
      say "Generated file for #{team_member['login']}."
    else
      say "File for #{team_member['login']} already exists. Skipping..."
    end
  end
end

desc "Create a Rackspace server if it doesn't already exist.

The configuration of the created server will be:
  - 512MB RAM
  - Ubuntu Lucid 10.04

Requires the following envvars to be set:
  - RACKSPACE_USERNAME
  - RACKSPACE_API_KEY"
task :create_server, :project do |t, args|

  # Ensure envvars set
  required_envvars = [
    'RACKSPACE_USERNAME',
    'RACKSPACE_API_KEY',
  ]
  required_envvars.each do |envvar|
    raise "The following environment variables must be set: #{required_envvars.join(', ')}" if ENV[envvar].nil?
  end

  require 'fog'
  connection = Fog::Compute.new({
    :provider           => 'Rackspace',
    :rackspace_username => ENV['RACKSPACE_USERNAME'],
    :rackspace_api_key  => ENV['RACKSPACE_API_KEY'],
    :rackspace_endpoint => Fog::Compute::RackspaceV2::ORD_ENDPOINT,
    :version => :v2,
  })
  servers = connection.servers
  if servers.collect{ |i| i.name }.member? args.project
    p "A server named #{args.project} already exists. Aborting server creation."
  else
    p "A server named #{args.project} doesn't yet exist. Creating it..."
    flavor_id = "2" # 512MB
    image_id = "d531a2dd-7ae9-4407-bb5a-e5ea03303d98" # Lucid LTS
    server = connection.servers.create({
      :name => args.project,
      :image_id => image_id,
      :flavor_id => flavor_id,
    })
    p "Waiting for server to build..."
    server.wait_for { ready? }
    password = (0...32).map{65.+(rand(25)).chr}.join
    p "Setting root password..."
    server.change_admin_password(password)
    p "Server provisioned!"
    p "IP address: #{server.ipv4_address}"
    p "Root password: #{password}"
  end
end

namespace :vagrant do
  desc "Restarts the network service inside the VM.

  This often needs to be run when you've changes wifi hotspots or have been
  disconnected temporily. If the VM is taking a long to time provision, or timing
  out, run this task."
  task :restart_networking do
    env = Vagrant::Environment.new
    env.vms.each do |id, vm|
      raise Vagrant::Errors::VMNotCreatedError if !vm.created?
      raise Vagrant::Errors::VMNotRunningError if vm.state != :running

      vm.channel.sudo("/etc/init.d/networking restart")
    end
  end
end

desc "Create and update config file."
task :configure do
  require 'highline/import'
  require 'hashery/ordered_hash'

  # Override output delimiter for defaults from "|blah|" to "<blah>".
  class HighLine
    class Question
      private
      def append_default()
        if @question =~ /([\t ]+)\Z/
          @question << "<#{@default}>#{$1}"
        elsif @question == ""
          @question << "<#{@default}>  "
        elsif @question[-1, 1] == "\n"
          @question[-2, 0] =  "  <#{@default}>"
        else
          @question << "  <#{@default}>"
        end
      end
    end
  end

  config_defaults = Hashery::OrderedHash.new
  config_defaults['domain'] = 'ci.example.com'
  config_defaults['repo'] = 'https://github.com/myplanetdigital/drupal-skeletor.git'
  config_defaults['branch'] = 'develop'
  config_defaults['password'] = 'sekret'
  config_defaults['timezone'] = 'America/Toronto'
  config_defaults['build_jobs'] = [
    'commit',
    'deploy-dev',
    'deploy-stage',
    'deploy-prod',
  ]
  config_defaults['manual_trigger_jobs'] = [
    'deploy-stage',
    'deploy-prod',
  ]

  config_defaults.each_key do |key|
    conf[key] = ask("#{key}?  ") do |q|

      # If Array, convert to string for easy default display.
      # (We'll convert back later.)
      q.default = conf[key] || config_defaults[key]
      if config_defaults[key].kind_of?(Array)
        q.default = q.default.join(',')
      end

      # Make sure we don't have whitespace, especially for joined arrays.
      q.whitespace = :remove

    end.to_s # << See: https://github.com/engineyard/engineyard/pull/152
  end

  # Split the string into an array if the default is of that type.
  config_defaults.delete_if { |k,v| !v.kind_of?(Array) }.each do |key, array_string|
    conf[key] = conf[key].split(',')
  end

  # Write config.yml
  File.open('roles/config.yml', 'w') do |out|
    YAML::dump(conf, out)
  end
end

namespace :opscode do
  desc "Programmatically sign up for a free Hosted Chef server with Opscode."
  task :platform_signup do
    require 'highline/import'

    form_fields = %w{
      user_first_name
      user_last_name
      user_unique_name
      user_email_address
      user_company
      user_country
      user_state
      user_phone_number
      user_password
      user_password_confirmation
    }

    form_values = {}
    form_fields.each do |field|
      form_values[field] = ask("Enter your #{field.gsub('user_', '').gsub('_', ' ')}:  ") do |q|
        q.echo = true
      end
    end

    require 'watir-webdriver'
    b = Watir::Browser.new
    b.goto 'https://community.opscode.com/users/new'
    form_values.each do |id, value|
      b.text_field(:id => id).set value
    end
    b.element.h2(:class => 'captcha').wd.location_once_scrolled_into_view
    b.checkbox(:id => 'accept_terms_of_service').set

    captcha = ask("What does the CAPTCHA in the browser say?  ") do |q|
      q.echo = true
    end
    b.text_field(:id => 'recaptcha_response_field').set captcha

    b.button(:id => 'submit').click

    #if b.text.include? "Username has already been taken" do
    #  form_values['user_unique_name'] = ask("Username already taken. Please try another:  ") do |q|
    #    q.echo = true
    #  end
    #  b.button(:id => 'submit').click
    #end
  end
end

task :setup_webhook, :github_repo  do |t, args|
  require 'hub'
  require 'ostruct'

  module Hub
    class GitHubAPI
      def create_webhook(project, hook_data)
        res = get "https://%s/repos/%s/%s/hooks" %
          [api_host(project.host), project.owner, project.name]
        res.error! unless res.success?
      end
    end
  end

  project = OpenStruct.new
  project.host = 'github.com'
  project.owner = args.github_repo.split('/')[0]
  project.name = args.github_repo.split('/')[1]

  hook_data = OpenStruct.new
  hook_data.name = 'jenkins'
  hook_data.config = { :jenkins_hook_url => "http://#{conf['domain']}/github-webhook/" }

  require 'pp'
  pp hook_data.to_s
  pp project.to_s

  # Use hub gem to authenticate against API.
  @api_client = Hub::Commands.send(:api_client)
  @api_client.create_webhook(project, hook_data)

end
