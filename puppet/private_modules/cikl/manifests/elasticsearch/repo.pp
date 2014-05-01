class cikl::elasticsearch::repo {
  if !defined(Class['apt']) {
    class { 'apt': }
  }
  apt::key { 'cikl::repositories::elasticsearch':
    key         => 'D88E42B4',
    key_server  => 'pgp.mit.edu'
  }
  apt::source { 'elasticsearch':
    location    => "http://packages.elasticsearch.org/elasticsearch/1.0/debian",
    release     => 'stable',
    repos       => 'main',
    include_src => false,
    require     => Apt::Key['cikl::repositories::elasticsearch']
  }
}



