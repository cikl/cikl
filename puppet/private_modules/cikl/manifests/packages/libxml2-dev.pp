class cikl::packages::libxml2-dev () {
  $package_name = $::osfamily ? {
    'Debian' => 'libxml2-dev',
    'RedHat' => 'libxml2-devel',
    default  => undef
  }

  if ($package_name == undef) {
    fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
  }

  cikl::package { 'cikl::packages::libxml2-dev':
    package_name => $package_name
  }
}
