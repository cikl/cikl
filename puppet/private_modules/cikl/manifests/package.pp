define cikl::package (
  $package_name,
  $ensure = 'present'
) {

  if (!defined(Package[$name])) {
    package { $name:
      name   => $package_name,
      ensure => $ensure
    }
  }
}
