class cikl::nginx::config () {
  include cikl::nginx::params

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
  }

  file { $cikl::nginx::params::configfile:
    content => template('cikl/nginx.conf.erb'),
  }

  file { $cikl::nginx::params::conf_enabled:
    ensure => $cikl::nginx::params::configfile,
    require => File[$cikl::nginx::params::configfile]
  }
}
