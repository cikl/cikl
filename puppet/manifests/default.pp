stage { "init": before => Stage['main'] }


class fix_resolvconf {
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

class { 'cikl::repositories': 
  stage => 'init'
}

class { 'fix_resolvconf': 
  stage  => 'init',
  before => Class['cikl::repositories']
}

class { 'cikl':
}

$network_interfaces = hiera('network_interfaces')
create_resources ( cikl::net, $network_interfaces )
