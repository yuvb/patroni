#
# Cookbook Name:: .
# Recipe:: node_preper
#
# Copyright (c) 2017 The Authors, All Rights Reserved.

include_recipe 'poise-python'

# Add postgres repository
apt_repository 'postgres' do
  uri        'http://apt.postgresql.org/pub/repos/apt/'
  distribution 'xenial-pgdg'
  components ['main']
  key 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
end

apt_update 'update'

# Install packages
package %w(postgresql-9.6 postgresql-server-dev-9.6 ntp python-yaml python-pip etcd git)

# Install requirements
current_dir = File.dirname(__FILE__)
pip_requirements "#{current_dir}/../files/default/requirements.txt"
