class cikl::worker {
  contain cikl::worker::service
  contain cikl::worker::package
  contain cikl::worker::config

  Class['cikl::worker::package'] -> Class['cikl::worker::service']
  Class['cikl::worker::config'] -> Class['cikl::worker::service']
}



