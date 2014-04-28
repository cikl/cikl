class cikl (
  $rabbitmq_host     = $cikl::params::rabbitmq_host,
  $rabbitmq_port     = $cikl::params::rabbitmq_port,
  $rabbitmq_username = $cikl::params::rabbitmq_username, 
  $rabbitmq_password = $cikl::params::rabbitmq_password,
  $rabbitmq_vhost    = $cikl::params::rabbitmq_vhost,
  $use_perlbrew      = $cikl::params::use_perlbrew,
  $elasticsearch_host   = $cikl::params::elasticsearch_host,
  $elasticsearch_port   = $cikl::params::elasticsearch_port,
  $nginx_hostname       = $cikl::params::nginx_hostname,
  $worker_user          = $cikl::params::worker_user,
  $worker_group         = $cikl::params::worker_group,
) inherits cikl::params {
  $kibana_root          = $cikl::params::kibana_root
  $kibana_base          = $cikl::params::kibana_base
  $kibana_dashboard     = $cikl::params::kibana_dashboard
}
