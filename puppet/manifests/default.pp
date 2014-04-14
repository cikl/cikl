require cikl::repositories

package { 'curl':
}

package { 'java7':
  name => 'openjdk-7-jre-headless',
  ensure => latest
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
  require => [ Class['cikl::repositories'], Package['java7'] ]
}

class { 'rabbitmq':
  require => Package['curl']
}

class { 'logstash':
  require => [ 
    Class['cikl::repositories', 'rabbitmq'], 
    Package['java7'], 
    Service['elasticsearch']
    ]
}

### Cikl stuff.
package { 'build-essential': }
package { 'cpanminus': }
package { 'libxml2-dev': }

exec { 'install Cikl': 
  command => '/usr/bin/cpanm --notest --skip-satisfied Cikl Cikl::RabbitMQ',
  require => Package['build-essential', 'cpanminus', 'libxml2-dev']
}


