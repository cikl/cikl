class cikl::packages::java7 {
  cikl::package { 'cikl::packages::java7':
    package_name => 'openjdk-7-jre-headless',
    ensure  => latest
  }
}
