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
  elasticsearch_cluster_name => "vagrant_logstash"
}

#class {'jruby': 
#  version => '1.7.11'
#}
