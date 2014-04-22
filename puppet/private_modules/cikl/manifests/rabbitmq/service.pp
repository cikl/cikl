class cikl::rabbitmq::service {
  service { 'cikl::rabbitmq::service': 
    name       => 'rabbitmq-server',
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true
  }
}


