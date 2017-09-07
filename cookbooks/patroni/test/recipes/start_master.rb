# # encoding: utf-8

# Inspec test for recipe patroni::start_master

# The Inspec reference, with examples and extensive documentation, can be
# found at https://docs.chef.io/inspec_reference.html

# Create patroni config data_dir
directory "#{node['patroni']['homedir']}" do
  owner 'postgres'
  group 'root'
  mode '0655'
  recursive true
  action :create
end

# Create patroni config file
template "::File.join(node['patroni']['homedir'], 'patroni.yml')" do
  source 'patroni.yml.erb'
  owner 'postgres'
  group 'root'
  mode '0655'
  variables(
    'node_ip': node['ipaddress'],
    'patroni_port': node['patroni']['patroni_port'],
    'postgresql_port': node['patroni']['postgresql_port'],
    'node_name': node['hostname'],
    'home_dir': node['patroni']['homedir']
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
