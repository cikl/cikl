class cikl::kibana {
  contain cikl::kibana::package
  contain cikl::kibana::config
  Class['cikl::kibana::package'] -> Class['cikl::kibana::config']
}



