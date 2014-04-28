class cikl::worker {
  contain cikl::worker::service
  contain cikl::worker::package
  contain cikl::worker::config
  contain cikl::worker::user

  if (defined(Class['cikl::rabbitmq'])) {
    Class['cikl::rabbitmq'] -> Class['cikl::worker']
  }
  if (defined(Class['cikl::logstash'])) {
    Class['cikl::logstash'] -> Class['cikl::worker']
  }

  Class['cikl::worker::user'] -> Class['cikl::worker::config']
  Class['cikl::worker::user'] -> Class['cikl::worker::service']
  Class['cikl::worker::package'] -> Class['cikl::worker::service']
  Class['cikl::worker::config'] -> Class['cikl::worker::service']
}



