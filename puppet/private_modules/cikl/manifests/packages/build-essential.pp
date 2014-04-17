class cikl::packages::build-essential () {
  case $::osfamily {
    'Debian' : {
      cikl::package { 'cikl::packages::build-essential':
        package_name => 'build-essential'
      }
    }

    'RedHat' : {
      exec { 'install redhat development tools':
        command => '/usr/bin/yum -d 0 -e 0 -y groupinstall "Development Tools"',
        unless  => '/usr/bin/yum -C grouplist "Development Tools"| /bin/grep "^Installed Groups"'
      }
    }

    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }
}


