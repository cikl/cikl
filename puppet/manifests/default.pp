stage { "init": before => Stage['main'] }


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

class { 'cikl':
}

class cikl::configure_network {
  $network_interfaces = hiera('network_interfaces')
  create_resources ( cikl::net, $network_interfaces )
}

class cikl::install_packages {
  $packages = hiera('install_packages')
  ensure_packages($packages)
}

include cikl::fix_resolvconf
include cikl::configure_network
include cikl::install_packages
hiera_include('classes')
