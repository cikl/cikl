class cikl::rabbitmq::repo {
  if !defined(Class['apt']) {
    class { 'apt': }
  }
  apt::source { 'cikl::repositories::rabbitmq':
    key         => '056E8E56',
    location    => "http://www.rabbitmq.com/debian/",
    release     => 'testing',
    repos       => 'main',
    include_src => false,
  }
}


