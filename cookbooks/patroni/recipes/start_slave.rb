#
# Cookbook Name:: patroni
# Recipe:: start_slave
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

require 'net/http'

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

# # Create system unit file for postgresql with patroni config
# template '/etc/systemd/system/postgresql_patroni.service' do
#   source 'postgresql_patroni.service.erb'
#   owner 'root'
#   group 'root'
#   mode 00644
#   variables(
#     'home_dir': node['patroni']['homedir'],
#     'node_name': node['hostname']
#   )
# end

uri = URI.parse("http://#{node['ipaddress']}:2379/v2/keys/service/batman/leader")
response = Net::HTTP.get_response(uri)
status = response.code

service 'patroni' do
  supports :status => true
  action [ :enable, :start ]
  only_if { status == '200' }
end
