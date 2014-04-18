class cikl::packages::java7 {
  cikl::package { 'cikl::packages::java7':
    debian   => 'openjdk-7-jre-headless',
    redhat   => 'java-1.7.0-openjdk'
  }
}
