# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_plugin "vagrant-rackspace"
Vagrant.require_plugin "vagrant-librarian-chef"
Vagrant.require_plugin "vagrant-omnibus"

case ENV['PROVISO_PROVIDER']
when /virtualbox/i, /vbox/i,
  ENV['VAGRANT_DEFAULT_PROVIDER'] = "virtualbox"
when /rackspace/i, nil
  ENV['VAGRANT_DEFAULT_PROVIDER'] = "rackspace"
end

ENV['LIBRARIAN_CHEF_TMP'] = File.expand_path("~/.librarian")

Vagrant.configure("2") do |config|
  config.vm.define "inception"

  config.vm.box = "dummy"
  config.vm.box_url = "https://github.com/mitchellh/vagrant-rackspace/raw/master/dummy.box"

  config.omnibus.chef_version = "11.4.4"
  #config.ssh.username = "patcon"
  config.ssh.private_key_path = Dir.glob(File.expand_path "~/.ssh/id_*").first

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

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

  unless ENV['RACKSPACE_USERNAME'].nil? || ENV['RACKSPACE_API_KEY'].nil?
    config.vm.provider :rackspace do |rs, override|
      rs.username = ENV['RACKSPACE_USERNAME']
      rs.api_key  = ENV['RACKSPACE_API_KEY']
      rs.public_key_path = Dir.glob(File.expand_path "~/.ssh/id_*.pub").first

      rs.flavor   = /512MB/
      rs.image    = /Lucid/
    end
  else
    config.vm.provider :managed do |man|
    end
  end

  # Compile-time pkg install (gcc & make for ruby-shadow) needs apt-get update first.
  config.vm.provision :shell, :inline => "sudo apt-get update"

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = [ "cookbooks", "cookbooks-override" ]
    chef.roles_path = "roles"
    chef.data_bags_path = "data_bags"

    chef.add_role "jenkins"
  end
end
