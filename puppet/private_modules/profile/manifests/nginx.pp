class profile::nginx (
  $kibana_root,
  $kibana_conf       = undef,
  $kibana_dashboards = undef,
  $elasticsearch_url = 'http://127.0.0.1:9200'
) inherits profile::base {

  $config_file  = "/etc/nginx/sites-available/cikl.conf"
  $config_enabled_symlink = "/etc/nginx/sites-enabled/cikl.conf"

  validate_re($elasticsearch_url, '^https?://.*')

  ensure_packages(['nginx'])

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    notify  => Service['nginx'],
    require => Package['nginx']
  } 

  file { $config_file:
    content => template('profile/nginx/nginx.conf.erb'),
    notify => Service['nginx'],
    require => Package['nginx']
  } ->
  file { $config_enabled_symlink:
    ensure => $config_file,
    notify => Service['nginx'],
    require => Package['nginx']
  }

  service { 'nginx':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    pattern    => 'nginx',
    require => Package['nginx']
  }
}
