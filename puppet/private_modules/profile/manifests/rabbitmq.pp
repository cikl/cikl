class profile::rabbitmq inherits profile::base {
  ensure_packages(['rabbitmq-server'])

  if !defined(Class['apt']) {
    class { 'apt': }
  }
  apt::source { 'rabbitmq':
    key         => '056E8E56',
    location    => "http://www.rabbitmq.com/debian/",
    release     => 'testing',
    repos       => 'main',
    include_src => false,
    before      => Package['rabbitmq-server']
  }

  service { 'rabbitmq-server': 
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['rabbitmq-server']
  }
}

