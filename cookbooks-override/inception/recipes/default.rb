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

template "/etc/default/jenkins" do
  cookbook "jenkins"
  notifies :restart, "service[jenkins]"
end

template "#{node['jenkins']['server']['home']}/config.xml" do
  source "jenkins-config.xml.erb"
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['group']
  mode "0644"
  notifies :restart, "service[jenkins]"
end

job_name = "build-int"

job_config = File.join(node['jenkins']['node']['home'], "#{job_name}-config.xml")

directory node['jenkins']['node']['home'] do
  owner node['jenkins']['server']['user']
  group node['jenkins']['server']['group']
end

jenkins_job job_name do
  action :nothing
  config job_config
end

repo = node['inception']['repo']
github_url = "http://github.com/#{repo.sub(/^git@github.com:(.*).git$/, '\\1')}"

template job_config do
  source "build-int-config.xml.erb"
  variables({
    :repo => repo,
    :github_url => github_url,
    :branch => node['inception']['branch'],
  })
  notifies :update, resources(:jenkins_job => job_name), :immediately
end
