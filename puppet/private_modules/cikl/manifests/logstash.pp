class cikl::logstash {
  contain cikl::logstash::deps
  contain cikl::logstash::disable-web
  contain cikl::logstash::package
  contain cikl::logstash::config

  if (defined(Class['cikl::rabbitmq'])) {
    Class['cikl::rabbitmq'] -> Class['cikl::logstash']
  }
  if (defined(Class['cikl::elasticsearch'])) {
    Class['cikl::elasticsearch'] -> Class['cikl::logstash']
  }

  Class['cikl::logstash::deps'] -> Class['cikl::logstash::package']
  Class['cikl::logstash::disable-web'] -> Class['cikl::logstash::package']
  Class['cikl::logstash::config'] -> Class['cikl::logstash::package']
}


