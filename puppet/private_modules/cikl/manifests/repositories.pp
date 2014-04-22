class cikl::repositories {
  case $::osfamily {
    'Debian': {

      if !defined(Class['apt']) {
        class { 'apt': }
      }

      apt::key { 'cikl::repositories::rabbitmq':
        key         => '056E8E56',
      }

      apt::key { 'cikl::repositories::elasticsearch':
        key         => 'D88E42B4',
        key_server  => 'pgp.mit.edu'
      }

      apt::source { 'cikl::repositories::rabbitmq':
        location    => "http://www.rabbitmq.com/debian/",
        release     => 'testing',
        repos       => 'main',
        include_src => false,
        require     => Apt::Key['cikl::repositories::rabbitmq']
      }

      apt::source { 'cikl::repositories::logstash':
        location    => "http://packages.elasticsearch.org/logstash/1.4/debian",
        release     => 'stable',
        repos       => 'main',
        include_src => false,
        require     => Apt::Key['cikl::repositories::elasticsearch']
      }
      
      apt::source { 'cikl::repositories::elasticsearch':
        location    => "http://packages.elasticsearch.org/elasticsearch/1.0/debian",
        release     => 'stable',
        repos       => 'main',
        include_src => false,
        require     => Apt::Key['cikl::repositories::elasticsearch']
      }

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
