class cikl_logstash::repo {
  if !defined(Class['apt']) {
    class { 'apt': }
  }
  apt::key { 'cikl::repositories::logstash':
    key         => 'D88E42B4',
    key_server  => 'pgp.mit.edu'
  }
  apt::source { 'logstash':
    location    => "http://packages.elasticsearch.org/logstash/1.4/debian",
    release     => 'stable',
    repos       => 'main',
    include_src => false,
    require     => Apt::Key['cikl::repositories::logstash']
  }
}



