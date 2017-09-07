#
# Cookbook Name:: etcd
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

raise 'You should provide coreect etcd nodes Ip list "{node_name" => "Ip address}"' if node['etcd']['nodes'].empty?
raise "Current node doesn't exist in nodes list" if ! node['etcd']['nodes'].values.include? node['ipaddress']

package 'etcd' do
  action :install
end

# Systemd unit file

commands = [
  "/usr/bin/etcd --name #{node['hostname']}",
  "--data-dir #{node['etcd']['data_dir']}",
  "--listen-client-urls http://#{node['ipaddress']}:2379",
  "--advertise-client-urls http://#{node['ipaddress']}:2379",
  "--listen-peer-urls http://#{node['ipaddress']}:2380",
  "--initial-advertise-peer-urls http://#{node['ipaddress']}:2380",
  '--initial-cluster',
  "--initial-cluster-token #{node['etcd']['cluster-token']}",
  '--initial-cluster-state new'
]


node['etcd']['nodes'].each_with_index do |(key, value), index |
  if index == 0
      commands[6] = commands[6] + ' ' + "#{key}=http://#{value}:2338"
  else
      commands[6] = commands[6] + ',' + "#{key}=http://#{value}:2338"
  end
end

commands = commands.join(' ')

template '/etc/systemd/system/etcd_cluster.service' do
  source 'etcd_cluster.service.erb'
  owner 'root'
  group 'root'
  mode 00644
  variables(
    'command': commands
  )
end

service 'etcd_cluster' do
  supports :status => true
  action [ :enable, :start ]
end
