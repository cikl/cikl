class cikl::logstash::disable-web {
  file { 'cikl::logstash::disable-web':
    path    => '/etc/init/logstash-web.override',
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => 'manual'
  }
}

