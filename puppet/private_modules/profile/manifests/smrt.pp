class profile::smrt (
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/'
) inherits profile::base {

  class profile::smrt::deps {
    ensure_packages(['build-essential', 'libxml2-dev', 'libssl-dev'])
  }

  include profile::smrt::deps

  if (!defined(Class['::perl'])) {
    class { '::perl': 
    }
  }

  file { 'cikl-conf': 
    path    => "/etc/cikl.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/smrt/cikl.conf.erb')
  }

  perl::module { 'Cikl': 
    require          => Class['profile::smrt::deps'],
    exec_environment => [ 'PERL_CPANM_OPT=--notest --skip-satisfied' ],
    exec_timeout          => 0
  } ->
  perl::module { 'Cikl::RabbitMQ': 
    exec_environment => [ 'PERL_CPANM_OPT=--notest --skip-satisfied' ],
    exec_timeout          => 0
  }
}


