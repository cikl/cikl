class cikl::repositories {
  case $::osfamily {
    'Debian': {
      exec { 'cikl::repositories': 
        command => '/usr/bin/apt-get update -y -qq',
        # Only run update if we have never updated, or if it's 
        # been more than two hours since the last update.
        onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || (/usr/bin/find /var/cache/apt/pkgcache.bin -mmin +120 | grep pkgcache)'",
      }
    }
    'RedHat': {
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }

  }
}
