class cikl::common_packages () {
  require cikl::repositories

  package { 'cikl::common_packages::curl':
    name => "curl"
  }

  package { 'cikl::common_packages::build-essential': 
    name => "build-essential"
  }

  package { 'cikl::common_packages::cpanminus': 
    name => "cpanminus"
  }

  package { 'cikl::common_packages::libxml2-dev': 
    name => "libxml2-dev"
  }

  package { 'cikl::common_packages::java7':
    name    => 'openjdk-7-jre-headless',
    ensure  => latest
  }
}

