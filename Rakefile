require 'vagrant'

class String
  # Strip leading whitespace from each line that is the same as the
  # amount of whitespace on the first line of the string
  # Leaves _additional_ indentation on later lines intact
  # SEE: http://stackoverflow.com/a/5638187/504018
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
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

desc "Initialize Inception Jenkins environment."
task :init do
  # Write the config file if doesn't exist.
  unless File.exists?("roles/config.yml")
    p "Creating roles/config.yml..."
    conf = File.open("roles/config.yml", "w")
    conf.puts <<-EOF.unindent
      # `repo` expects a GitHub repo.
      repo: https://github.com/myplanetdigital/myplanet.git
      branch: develop

      # For timestamps in Jenkins UI
      timezone: America/Toronto

      # Only the entries below in the `users` database will be acted on.
      # Each user created will be given passwordless sudo access.
      # Example: [user1, user2]
      users: [patcon]

      # This domain name will be used to contruct URL's for viewing workspaces of
      # Jenkins jobs.
      domain: inception.dev

      github:
        organization: myplanetdigital
        # In order to use GitHub authentication, you'll need to register an app
        # See: https://github.com/settings/applications
        # Leaving these blank will use Jenkins database for authentication.
        # (Do not try GitHub authentication on Vagrant as it will break Jenkins.)
        client_id:
        secret:
    EOF
    conf.close
  else
    p "config.yml already exists. Skipping write..."
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
