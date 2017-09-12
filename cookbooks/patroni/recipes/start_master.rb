#
# Cookbook Name:: patroni
# Recipe:: start_master
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

# Create patroni config data_dir
directory "#{node['patroni']['homedir']}" do
  owner 'postgres'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Get network for replication
ip = node['ipaddress'].split('.')
ip[-1] = '1'
lan = ip.join('.') + node['patroni']['netmask']

# Create patroni config file
template ::File.join(node['patroni']['homedir'], 'patroni.yml') do
  source 'patroni.yml.erb'
  owner 'postgres'
  group 'root'
  mode '0655'
  variables(
    'node_ip': node['ipaddress'],
    'patroni_port': node['patroni']['patroni_port'],
    'postgresql_port': node['patroni']['postgresql_port'],
    'node_name': node['hostname'],
    'home_dir': node['patroni']['homedir'],
    'lan': lan
  )
end

# Create systemd unit file
template '/etc/systemd/system/patroni.service' do
  source 'patroni.service.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    'home_dir': node['patroni']['homedir']
  )
end

# Create system unit file for postgresql with patroni config
template '/etc/systemd/system/postgresql_patroni.service' do
  source 'postgresql_patroni.service.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    'home_dir': node['patroni']['homedir'],
    'node_name': node['hostname']
  )
end

service 'patroni' do
  supports :status => true
  action [ :enable, :start ]
end

# Check patroni status
remote_file "wait patroni startup" do
  path ::File.join(node['patroni']['homedir'], "dummy")
  source "http://#{node['ipaddress']}:2379/v2/keys/service/batman/leader"
  retries 10
  retry_delay 10
  backup false
  not_if { ::File.exist?(::File.join(node['patroni']['homedir'],"install_completed.txt")) }
  notifies :start, 'service[postgresql_patroni]', :immediately
end

service 'postgresql_patroni' do
  supports :status => true
  action [ :enable, :start ]
end

file ::File.join(node['patroni']['homedir'],"install_completed.txt") do
  owner 'root'
  group 'root'
  mode 00755
  action :create
end
