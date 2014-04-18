class cikl::packages::build-essential () {
  if ($::osfamily == 'RedHat') {
    exec { 'install redhat development tools':
      command => '/usr/bin/yum -d 0 -e 0 -y groupinstall "Development Tools"',
      unless  => '/usr/bin/yum -C grouplist "Development Tools"| /bin/grep "^Installed Groups"'
    }
  } else {

    cikl::package { 'cikl::packages::build-essential':
      debian => 'build-essential',
    }
  }
}


