class cikl::packages::java7 {
  $package_name = $::osfamily ? {
    'Debian' => 'openjdk-7-jre-headless',
    'RedHat' => 'java-1.7.0-openjdk',
    default  => undef
  }

  if ($package_name == undef) {
    fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
  }

  cikl::package { 'cikl::packages::java7':
    package_name => $package_name,
    ensure  => latest
  }
}
