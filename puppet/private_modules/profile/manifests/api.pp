class profile::api (
  $local_path,
  $gem_root      = '/opt/cikl/api/gems',
  $user          = 'cikl_api',
  $group         = 'cikl_api',
  $server_config       = "/etc/cikl_api.conf",
  $server_run_path     = '/var/run/cikl_api',
  $server_log_path     = "/var/log/cikl_api"
) inherits profile::base {
  $server_pid_file     = "$server_run_path/cikl_api.pid"
  $server_socket_path  = "$server_run_path/socket"

  ensure_packages(['libxml2-dev', 'libssl-dev'])

  bundler::install { "api":
    source_path => $local_path,
    gem_root    => $gem_root,
    notify      => Service['profile::api::service'],
    require => [
      Package['libxml2-dev', 'libssl-dev']
    ],
  }

  group { 'profile::api::group':
    name => $group,
    ensure => 'present'
  } ->
  user { 'profile::api::user':
    name    => $user,
    ensure  => 'present',
    gid     => $group,
    shell   => '/usr/sbin/nologin'
  }

  file { 'profile::api::server_config': 
    path    => $server_config,
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/api/server.conf.erb'),
    notify  => Service['profile::api::service'],
  }

  file { 'profile::api::upstart-pre': 
    path    => "/etc/init/cikl-api-pre.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/api/cikl-api-pre-upstart.conf.erb'),
    notify  => Service['profile::api::service'],
    require => [
      User['profile::api::user'],
      Group['profile::api::group'],
    ]
  }

  file { 'profile::api::upstart': 
    path    => "/etc/init/cikl-api.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/api/cikl-api-upstart.conf.erb'),
    notify  => Service['profile::api::service'],
    require => [
      User['profile::api::user'],
      Group['profile::api::group'],
      File['profile::api::server_config'],
      File['profile::api::upstart-pre'],
    ]
  }

  service { 'profile::api::service': 
    name       => 'cikl-api',
    ensure     => 'running',
    provider   => 'upstart',
    hasstatus  => true,
    hasrestart => false, # This gets upstart to properly reload things.
    #pattern    => 'dns_api',
    subscribe  => [
     File['profile::api::upstart']
    ]
  }

}


