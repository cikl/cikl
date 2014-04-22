class cikl (
  $elasticsearch_cluster_name = $cikl::params::elasticsearch_cluster_name,
  $elasticsearch_template = $cikl::params::elasticsearch_template,
  $rabbitmq_host     = $cikl::params::rabbitmq_host,
  $rabbitmq_port     = $cikl::params::rabbitmq_port,
  $rabbitmq_username = $cikl::params::rabbitmq_username, 
  $rabbitmq_password = $cikl::params::rabbitmq_password,
  $rabbitmq_vhost    = $cikl::params::rabbitmq_vhost,
  $use_perlbrew      = $cikl::params::use_perlbrew,
  $elasticsearch_host   = $cikl::params::elasticsearch_host,
  $elasticsearch_port   = $cikl::params::elasticsearch_port,
  $nginx_hostname       = $cikl::params::nginx_hostname,
) inherits cikl::params {
  $kibana_root          = $cikl::params::kibana_root
  $kibana_base          = $cikl::params::kibana_base
  $kibana_dashboard     = $cikl::params::kibana_dashboard

  class { 'cikl::rabbitmq': }
  class { 'cikl::elasticsearch': }
  class { 'cikl::logstash': }
  class { 'cikl::worker': }

  class { 'cikl::smrt': }
  class { 'cikl::nginx': }
  class { 'cikl::kibana': }

  Class['cikl::rabbitmq'] -> Class['cikl::logstash']
  Class['cikl::elasticsearch'] -> Class['cikl::logstash']

  Class['cikl::rabbitmq'] -> Class['cikl::worker']
  Class['cikl::logstash'] -> Class['cikl::worker']
}
