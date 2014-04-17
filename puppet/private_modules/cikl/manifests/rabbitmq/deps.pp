class cikl::rabbitmq::deps () {
  ensure_packages(['curl'])

  case $::osfamily {
    'RedHat': {
      include cikl::repo::yum
      ensure_packages(['erlang'])
      Class['cikl::repo::yum'] -> Package['erlang']
    }
  }
}




