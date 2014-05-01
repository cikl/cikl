class cikl_worker {
  contain cikl_worker::service
  contain cikl_worker::package
  contain cikl_worker::config

  if (defined(Class['cikl::rabbitmq'])) {
    Class['cikl::rabbitmq'] -> Class['cikl_worker']
  }
  if (defined(Class['cikl::logstash'])) {
    Class['cikl::logstash'] -> Class['cikl_worker']
  }

  Class['cikl_worker::package'] -> Class['cikl_worker::service']
  Class['cikl_worker::config'] -> Class['cikl_worker::service']
}



