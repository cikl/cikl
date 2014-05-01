class cikl_logstash::package {
  class { '::logstash':
    manage_repo  => false,
  }
  contain 'logstash'
}


