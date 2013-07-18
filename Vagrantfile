# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
current_dir = File.dirname(__FILE__)
config_file = File.join(current_dir, "roles/config.yml")
yml_config = YAML.load_file(config_file)

Vagrant.require_plugin "vagrant-cachier"
Vagrant.require_plugin "vagrant-rackspace"
Vagrant.require_plugin "vagrant-librarian-chef"
Vagrant.require_plugin "vagrant-omnibus"
Vagrant.require_plugin "vagrant-managed-servers"

# Use rackspace unless credential config missing.
if ENV['VAGRANT_DEFAULT_PROVIDER'].nil?
  unless ENV['RACKSPACE_USERNAME'].nil? || ENV['RACKSPACE_API_KEY'].nil?
    ENV['VAGRANT_DEFAULT_PROVIDER'] = "rackspace"
  else
    ENV['VAGRANT_DEFAULT_PROVIDER'] = "managed"
  end
end

# Move librarian scratch space out of project root so it doesn't rsync.
ENV['LIBRARIAN_CHEF_TMP'] = File.expand_path("~/.librarian")

Vagrant.configure("2") do |config|
  config.vm.define "inception"

  config.vm.hostname = yml_config['domain']

  config.vm.box = "lucid64"

  config.omnibus.chef_version = "11.4.4"

  config.vm.network :forwarded_port, guest: 8080, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--memory", "3000"]
    override.cache.auto_detect = true
  end

  config.vm.provider :rackspace do |rs, override|
    rs.username = ENV['RACKSPACE_USERNAME']
    rs.api_key  = ENV['RACKSPACE_API_KEY']
    rs.public_key_path = Dir.glob(File.expand_path "~/.ssh/id_*.pub").first

    rs.flavor   = /512MB/
    rs.image    = /Lucid/

    override.ssh.username = "root"
    override.ssh.private_key_path = Dir.glob(File.expand_path "~/.ssh/id_*").first
    override.vm.box_url = "https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box"
  end

  config.vm.provider :managed do |mngd, override|
    mngd.server = yml_config['ip_address']
    override.ssh.username = `git config --get github.user`.chomp
    override.vm.box_url = "https://github.com/tknerr/vagrant-managed-servers/raw/master/dummy.box"
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = [ "cookbooks", "cookbooks-override" ]
    chef.roles_path = "roles"
    chef.data_bags_path = "data_bags"

    chef.add_role "jenkins"

    chef.log_level = :debug unless ENV['INCEPTION_DEBUG'].nil?

    chef.json = {
      :authorization => {
        :sudo => {
          :users => ["vagrant"],
        },
      },
      :openssh => {
        :server => {
          :permit_root_login => "yes"
        },
      },
    }

    chef.json.merge!(yml_config)
  end
end
