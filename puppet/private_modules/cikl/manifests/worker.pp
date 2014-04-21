class cikl::worker {
  class { 'cikl::worker::config': }
  class { 'cikl::worker::package': }
  class { 'cikl::worker::service': }

  Class['cikl::worker::package'] -> Class['cikl::worker::service']
  Class['cikl::worker::config'] -> Class['cikl::worker::service']
}



