class cikl::logstash::package {
  class { '::logstash':
    manage_repo  => false,
  }
  contain 'logstash'
}


