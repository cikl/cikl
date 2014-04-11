require cikl::repositories
require cikl::java7

package { 'curl':
}

class { 'elasticsearch':
  config => {
    'cluster.name' => 'vagrant_elasticsearch',
      'node.name' => $::ipaddress,
      'index' => {
        'number_of_replicas' => '0',
        'number_of_shards' => '1',
      },
      'network' => {
        'host' => '0.0.0.0',
      }
  },
  require => [ Class['cikl::repositories'], Class['cikl::java7'] ]
}

class { 'rabbitmq':
  require => Package['curl']
}

class { 'logstash':
  require => [ 
    Class['cikl::repositories'], 
    Class['cikl::java7'], 
    Service['elasticsearch'],
    Class['rabbitmq'] 
    ]
}
