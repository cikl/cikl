class cikl::java7 {
  case $::operatingsystem {
    debian: { $java7_package_name = "openjdk-7-jre-headless" }
    ubuntu: { $java7_package_name = "openjdk-7-jre-headless" }
    default: { fail("Unrecognized operating system") }
  }

  require cikl::repositories

  anchor {'cikl::java7::begin':}
  anchor {'cikl::java7::end': 
    require => Anchor['cikl::java7::begin']
  }

  package { 'java7':
    name => $java7_package_name,
    ensure => latest,
    require           => Anchor['cikl::java7::begin'],
    before            => Anchor['cikl::java7::end']
  } 

}
