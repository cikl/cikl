class cikl::rabbitmq {
  include cikl::packages::curl

  class { '::rabbitmq':
    require => Class['cikl::packages::curl']
  }

}
