class cikl::rabbitmq (
  $host     = 'localhost',
  $port     = 5672,
  $username = 'guest',
  $password = 'guest',
  $vhost    = '/') 
{

  include cikl::common_packages

  class { '::rabbitmq':
    require => Package['cikl::common_packages::curl']
  }

}
