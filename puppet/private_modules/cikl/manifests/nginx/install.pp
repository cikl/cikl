class cikl::nginx::install () {
  ensure_packages(['nginx'])

  $nginx_cikl_conf = "/etc/nginx/sites-available/cikl.conf"
  $nginx_cikl_conf_enabled = "/etc/nginx/sites-enabled/cikl.conf"

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    require => Package['nginx']
  }

  file { $nginx_cikl_conf:
    content => template('cikl/nginx.conf.erb'),
    require => Package['nginx']
  }

  file { $nginx_cikl_conf_enabled:
    ensure => $nginx_cikl_conf
  }

  service { 'nginx':
    ensure    => 'running',
    enable    => true,
    subscribe => File[$nginx_cikl_conf_enabled]
  }
}
