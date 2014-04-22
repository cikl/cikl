class cikl::smrt () {
  contain cikl::smrt::deps
  contain cikl::smrt::package
  contain cikl::smrt::config

  Class['cikl::smrt::deps'] -> Class['cikl::smrt::package']
  Class['cikl::smrt::package'] -> Class['cikl::smrt::config']
}
