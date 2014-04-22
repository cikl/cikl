class cikl::params {

  $nginx_hostname   = $::fqdn
  $elasticsearch_host   = $::ipaddress
  $elasticsearch_port   = 9200

  $elasticsearch_cluster_name = 'vagrant_elasticsearch'
  $elasticsearch_template = '/etc/cikl-elasticsearch-template.json'

  $rabbitmq_host     = 'localhost'
  $rabbitmq_port     = 5672
  $rabbitmq_username = 'guest'
  $rabbitmq_password = 'guest'
  $rabbitmq_vhost    = '/'

  $kibana_base       = '/opt/kibana'
  $kibana_root       = '/opt/kibana/current'
  $kibana_dashboard = "cikl.json"

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
