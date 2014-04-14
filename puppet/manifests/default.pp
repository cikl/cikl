require cikl::repositories

package { 'curl':
}

package { 'java7':
  name => 'openjdk-7-jre-headless',
  ensure => latest
}
$es_cluster_name = 'vagrant_elasticsearch'
class { 'elasticsearch':
  config => {
    'cluster.name' => $es_cluster_name,
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

elasticsearch::plugin{'mobz/elasticsearch-head':
  module_dir => 'head'
}

class { 'rabbitmq':
  require => Package['curl']
}

### Cikl stuff.
package { 'build-essential': }
package { 'cpanminus': }
package { 'libxml2-dev': }

exec { 'install Cikl': 
  command => '/usr/bin/cpanm --notest --skip-satisfied Cikl Cikl::RabbitMQ',
  require => Package['build-essential', 'cpanminus', 'libxml2-dev']
}

# Generate cikl.conf
$rabbitmq_host = "localhost"
$rabbitmq_port = 5672
$rabbitmq_username = 'guest'
$rabbitmq_password = 'guest'
$rabbitmq_vhost = '/'

file { 'cikl-conf': 
  path    => "/etc/cikl.conf",
  owner   => "root",
  group   => "root",
  mode    => '0644',
  content => template('cikl/cikl.conf.erb')
}

$es_cikl_template = '/etc/logstash/elasticsearch-cikl-template.json'
file { 'elasticsearch-cikl-template': 
  path    => $es_cikl_template,
  owner   => "root",
  group   => "root",
  mode    => '0644',
  content => template('cikl/elasticsearch-cikl-template.json.erb')
}

class { 'logstash':
  require => [ 
    Class['cikl::repositories', 'rabbitmq'], 
    Package['java7'], 
    Service['elasticsearch']
    ]
}

logstash::configfile { 'input-rabbitmq':
  content => template('cikl/logstash-input-rabbitmq.conf.erb'),
  order   => 10
}

logstash::configfile { 'filter-event':
  content => template('cikl/logstash-filter-event.conf.erb'),
  order   => 20
}

logstash::configfile { 'output-elasticsearch':
  content => template('cikl/logstash-output-event.conf.erb'),
  require => File['elasticsearch-cikl-template'],
  order   => 30
}

#logstash::configfile { 'output-resolve':
#  content => template('cikl/logstash-output-resolve.conf.erb'),
#  order   => 30
#}

#class {'jruby': 
#  version => '1.7.11'
#}
