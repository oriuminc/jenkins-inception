#!/usr/bin/env ruby

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
