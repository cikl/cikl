class cikl::logstash {
  contain cikl::logstash::deps
  contain cikl::logstash::disable-web
  contain cikl::logstash::package
  contain cikl::logstash::config

  Class['cikl::logstash::deps'] -> Class['cikl::logstash::package']
  Class['cikl::logstash::disable-web'] -> Class['cikl::logstash::package']
  Class['cikl::logstash::config'] -> Class['cikl::logstash::package']
}


