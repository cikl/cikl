class cikl::elasticsearch {
  contain cikl::elasticsearch::deps
  contain cikl::elasticsearch::package

  Class['cikl::elasticsearch::deps'] -> Class['cikl::elasticsearch::package']
}


