class profile::common (
  $cikl_root = '/opt/cikl'
) {
  file { $cikl_root: 
    ensure => "directory"
  }
}
