class cikl_logstash {
  include cikl_logstash::repo
  contain cikl_logstash::deps
  contain cikl_logstash::disable-web
  contain cikl_logstash::package
  contain cikl_logstash::config

  if (defined(Class['cikl::rabbitmq'])) {
    Class['cikl::rabbitmq'] -> Class['cikl_logstash']
  }
  if (defined(Class['cikl::elasticsearch'])) {
    Class['cikl::elasticsearch'] -> Class['cikl_logstash']
  }

  Class['cikl_logstash::repo'] -> Class['cikl_logstash::package']
  Class['cikl_logstash::deps'] -> Class['cikl_logstash::package']
  Class['cikl_logstash::disable-web'] -> Class['cikl_logstash::package']
  Class['cikl_logstash::config'] -> Class['cikl_logstash::package']
}


