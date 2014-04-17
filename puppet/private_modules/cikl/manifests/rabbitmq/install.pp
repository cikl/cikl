class cikl::rabbitmq::install {
  include cikl::rabbitmq::deps

  class { '::rabbitmq':
    require       => Class['cikl::rabbitmq::deps']
  }

}
