class cikl::nginx () {
  contain cikl::nginx::package
  contain cikl::nginx::service
  contain cikl::nginx::config

  Class['cikl::nginx::package'] -> Class['cikl::nginx::config']
  Class['cikl::nginx::package'] -> Class['cikl::nginx::service']
  Class['cikl::nginx::config'] -> Class['cikl::nginx::service']
}
