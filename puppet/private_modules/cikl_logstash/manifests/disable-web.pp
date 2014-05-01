class cikl_logstash::disable-web {
  file { 'cikl_logstash::disable-web':
    path    => '/etc/init/logstash-web.override',
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => 'manual'
  }
}

