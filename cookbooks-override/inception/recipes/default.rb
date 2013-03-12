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
  members node['jenkins']['server']['user']
  append true
  action :modify
end

log "restarting jenkins" do
  notifies :stop, "service[jenkins]", :immediately
  notifies :create, "ruby_block[netstat]", :immediately
  notifies :start, "service[jenkins]", :immediately
  notifies :create, "ruby_block[block_until_operational]", :immediately
  action :nothing
end

# Set global Jenkins config
template "#{node['jenkins']['server']['home']}/config.xml" do
  source "jenkins-config.xml.erb"
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['group']
  mode "0644"
  notifies :write, "log[restarting jenkins]", :immediately
end

directory node['jenkins']['node']['home'] do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['group']
end

# In order to run authorized tasks (like updating job config), we need to
# authorize as a Jenkins user. We have Jenkins set to authorize against the
# unix user database, so we can use the `users` databag to build a URL and
# therefore use HTTP basic auth.

# Get any user and use the common password
auth_username = data_bag("users").first
auth_pass = node['user']['password']
auth_url = "http://#{auth_username}:#{auth_pass}@#{node['fqdn']}:#{node['jenkins']['server']['port']}"

repo = node['inception']['repo']
github_url = "http://github.com/#{repo.sub(/^.*[:\/](.*\/.*).git$/, '\\1')}"

build_jobs = node['inception']['build_jobs']
manual_trigger_jobs = node['inception']['manual_trigger_jobs']

# Prepare each job
[*build_jobs, nil].each_cons(2) do |job_name, next_job|
  job_config = File.join(node['jenkins']['node']['home'], "#{job_name}-config.xml")

  template job_config do
    source "job-config.xml.erb"
    variables({
      :repo => repo,
      :github_url => github_url,
      :branch => node['inception']['branch'],
      :job_name => job_name,
      :next_job => next_job,
      # Boolean flags for jobs.
      :triggered_by_github => (job_name == build_jobs.first),
      :manually_trigger_next_step => manual_trigger_jobs.include?(next_job),
    })
  end

  jenkins_job job_name do
    url auth_url
    config job_config
    action :update
  end

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
