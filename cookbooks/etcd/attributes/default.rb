default['etcd']['nodes'] = {node['hostname'] => node['ipaddress']} 
default['etcd']['cluster-token'] = 'my-etcd-token'
default['etcd']['data_dir'] = '/var/lib/etcd'
