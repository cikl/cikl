define cikl::package (
  $package_name,
  $ensure = 'present'
) {
  include cikl::update_repo

  if (!defined(Package[$name])) {
    package { $name:
      name    => $package_name,
      ensure  => $ensure,
      require => Class['cikl::update_repo']
    }
  }
}
