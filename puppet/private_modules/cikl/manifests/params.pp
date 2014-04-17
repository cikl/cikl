class cikl::params {

  $elasticsearch_cluster_name = 'vagrant_elasticsearch'
  $elasticsearch_template = '/etc/logstash/elasticsearch-cikl-template.json'

  $rabbitmq_host     = 'localhost'
  $rabbitmq_port     = 5672
  $rabbitmq_username = 'guest'
  $rabbitmq_password = 'guest'
  $rabbitmq_vhost    = '/'

  case $::osfamily {
    'Debian': {
    }
    'RedHat': {
      $use_perlbrew = true
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}
