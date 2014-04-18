define cikl::package (
  $debian = undef,
  $redhat = undef,
  $ensure = 'present'
) {

  $package_name = $::osfamily ? {
    'Debian' => $debian,
    'RedHat' => $redhat,
    default  => undef
  }

  if ($package_name == undef) {
    fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
  }

  if (!defined(Package[$name])) {
    package { $name:
      name    => $package_name,
      ensure  => $ensure
    }
  }
}
