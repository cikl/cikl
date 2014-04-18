class cikl::packages::libxml2-dev () {
  cikl::package { 'cikl::packages::libxml2-dev':
    debian     => 'libxml2-dev',
    redhat     => 'libxml2-devel',
  }
}
