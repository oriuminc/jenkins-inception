#!/usr/bin/env ruby

require 'vagrant'

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

  task :install_plugins do
    # TODO: Terrible using system here, need to look @ thor more to
    # see what we can do to make this sane, or possibly use mxin::command?
    plugins = `vagrant plugin list`.split("\n").map { |i| i.split(" ")[0] }
    %w{
      vagrant-librarian-chef
      vagrant-rackspace
      vagrant-omnibus
    }.each do |plugin|
      system "vagrant plugin install #{plugin}" unless plugins.include? plugin
    end
  end
end
