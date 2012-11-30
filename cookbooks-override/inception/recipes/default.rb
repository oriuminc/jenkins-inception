#
# Cookbook Name:: inception
# Recipe:: default
#
# Copyright 2012, Myplanet Digital, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

# Add so that we can set user passwords from databag
%w{
  make
  gcc
}.each do |pkg|
  package pkg do
    action :nothing
  end.run_action(:install)
end

chef_gem "ruby-shadow"

group "shadow" do
  members "jenkins"
  append true
  action :modify
end

# Set global Jenkins configs
%w{
  config
  hudson.plugins.ircbot.IrcPublisher
}.each do |file|
  template "#{node['jenkins']['server']['home']}/#{file}.xml" do
    source "global-#{file}.xml.erb"
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['group']
    mode "0644"
    notifies :restart, "service[jenkins]"
  end
end

# In order to run authorized tasks (like updating job config), we need to
# authorize as a Jenkins user. We have Jenkins set to authorize against the
# unix user database, so we can use the `users` databag to build a URL and
# therefore use HTTP basic auth.

# Get any user and use the common password
auth_username = data_bag("users").first
auth_pass = node['user']['password']

# @TODO: Jenkins restart need to happen right here or else Jenkins needs to be
# manually restarted.

# If login throws an error, assume it's because jenkins doesn't need it.
jenkins_cli "login --username #{auth_username} --password '#{auth_pass}'" do
  url "http://localhost:8080"
end

# Convert git repo to public URL
repo = node['inception']['repo']
github_url = "http://github.com/#{repo.sub(/^.*[:\/](.*\/.*).git$/, '\\1')}"

job_names = [
  "build-int",
  "commit-stage",
]

# Create jenkins HOME so we can drop job templates there.
directory node['jenkins']['node']['home'] do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['group']
end

# Build each job
job_names.each do |job_name|
  job_config = File.join(node['jenkins']['node']['home'], "#{job_name}-config.xml")

  jenkins_job job_name do
    action :nothing
    config job_config
  end

  template job_config do
    source "build-int-config.xml.erb"
    variables({
      :repo => repo,
      :github_url => github_url,
      :branch => node['inception']['branch'],
    })
    notifies :update, "jenkins_job[#{job_name}]", :immediately
    notifies :build, "jenkins_job[#{job_name}]", :immediately
  end
end

# Set up build-int to be served by apache
# @todo remove?
job_name = "build-int"
web_app job_name do
  template "site.conf.erb"
  port node['apache']['listen_ports'].to_a[0]
  server_name "#{job_name}.#{node['inception']['domain']}"
  server_aliases ["*.#{job_name}.#{node['inception']['domain']}"]
  docroot "#{node['jenkins']['server']['home']}/jobs/#{job_name}/workspace/build"
  notifies :reload, "service[apache2]"
end

%w{
  deploy
}.each do |type|
  cookbook_file "/var/lib/jenkins/#{type}.logparserules.txt" do
    source "#{type}.logparserules.txt"
    owner node['jenkins']['server']['user']
    group node['jenkins']['server']['group']
    mode "0644"
  end
end
