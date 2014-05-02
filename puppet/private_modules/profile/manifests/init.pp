class profile::base {
  stage { 'init': 
    before => Stage['main']
  }
  class cikl::fix_resolvconf {
    exec { 'refresh resolvconf':
      command     => '/sbin/resolvconf -u',
      refreshonly => true
    }

    file_line { 'add single-request-reopen to resolvconf':
      path   => '/etc/resolvconf/resolv.conf.d/base',
      line   => 'options single-request-reopen',
      match  => '^options single-request-reopen$',
      notify => Exec['refresh resolvconf']
    }
  }

  class cikl::configure_network {
    $network_interfaces = hiera_hash('network_interfaces', {})
    create_resources ( cikl::net, $network_interfaces )
  }

  class cikl::install_packages {
    $packages = hiera_array('install_packages', [])
    ensure_packages($packages)
  }

  class { 'cikl':
  }

  class { 'cikl::configure_network':
    stage => init
  }
  class { 'cikl::fix_resolvconf': 
    stage  => init,
    before => Class['cikl::configure_network']
  }

  class { 'cikl::install_packages':
    before => Class['cikl']
  }
}
