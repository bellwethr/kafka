#
# Cookbook Name::	kafka
# Description:: Base configuration for Kafka
# Recipe:: default
#
# Copyright 2012, Webtrends, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# == Recipes
include_recipe "java"

java_home   = node['java']['java_home']

user = node[:kafka][:user]
group = node[:kafka][:group]

if node[:kafka][:broker_id].nil? || node[:kafka][:broker_id].empty?
		node.set[:kafka][:broker_id] = node[:ipaddress].gsub(".","")
end

if node[:kafka][:broker_host_name].nil? || node[:kafka][:broker_host_name].empty?
		node.set[:kafka][:broker_host_name] = node[:fqdn]
end

log "Broker id: #{node[:kafka][:broker_id]}"
log "Broker name: #{node[:kafka][:broker_host_name]}"

# == Users

# setup kafka group
group group do
end

# setup kafka user
user user do
  comment "Kafka user"
  gid "kafka"
  home "/home/kafka"
  shell "/bin/noshell"
  supports :manage_home => false
end

# create the install directory
install_dir = node[:kafka][:install_dir]
kafka_version = node[:kafka][:kafka_version]

directory "#{install_dir}" do
  owner "root"
  group "root"
  mode 00755
  recursive true
  action :create
end

# create the log directory
directory node[:kafka][:log_dir] do
  owner   user
  group   group
  mode    00755
  recursive true
  action :create
end

# create the data directory
directory node[:kafka][:data_dir] do
  owner   user
  group   group
  mode    00755
  recursive true
  action :create
end

# pull the remote file only if we create the directory
tarball = "#{kafka_version}.tgz"
download_file = "#{node[:kafka][:download_url]}/#{tarball}"

remote_file "#{Chef::Config[:file_cache_path]}/#{tarball}" do
  source download_file
  mode 00644
  checksum node[:kafka][:checksum]
  ## notifies :run, "execute[tar]", :immediately
end

execute "tar" do
  user  "root"
  group "root"
  cwd install_dir
  ## action :nothing
  command "tar zxvf #{Chef::Config[:file_cache_path]}/#{tarball}"
end

# grab the zookeeper nodes that are currently available
zookeeper_pairs = Array.new
if not Chef::Config.solo
  search(:node, "role:zookeeper AND chef_environment:#{node.chef_environment}").each do |n|
    zookeeper_pairs << "#{n[:fqdn]}:#{n[:zookeeper][:client_port]}"
  end
end

# set up the configuration files
%w[server.properties log4j.properties consumer.properties zookeeper.properties producer.properties].each do |template_file|
  template "#{install_dir}/#{kafka_version}/config/#{template_file}" do
    source	"#{template_file}.erb"
    owner user
    group group
    mode  00755
    variables({
      :kafka => node[:kafka],
      :zookeeper_pairs => zookeeper_pairs
    })
  end
end

# fix perms and ownership
execute "chmod" do
  command "find #{install_dir} -name bin -prune -o -type f -exec chmod 644 {} \\; && find #{install_dir} -type d -exec chmod 755 {} \\;"
  action :run
end

execute "chown" do
  command "chown -R root:root #{install_dir}"
  action :run
end

execute "chmod" do
	command "chmod -R 755 #{install_dir}/#{kafka_version}/bin"
	action :run
end


# set up init script and launch the service
init_template = template "kafka" do
  path "/etc/init.d/kafka"
  source "kafka.erb"
  owner "root"
  group "root"
  mode "0755"
  variables({
    :install_dir => install_dir,
    :kafka_version => kafka_version,
    :log_dir => node[:kafka][:log_dir],
    :kafka_user => user,
    :kafka_group => group
  })
end
#force the init script to be created before the service is started
init_template.run_action(:create)

# start up Kafka broker
service "kafka" do
  supports :restart => true, :start => true, :stop => true, :reload => true, :status => true
  action :start
end 
