class profile::api (
  $local_path,
  $root          = '/opt/cikl_api',
  $user          = 'cikl_api',
  $group         = 'cikl_api',
  $unicorn_config       = "/etc/cikl_api_unicorn.rb",
  $unicorn_run_path     = '/var/run/unicorn_cikl_api',
  $unicorn_log_path     = "/var/log/cikl_api"
) inherits profile::base {
  $gems = "$root/gems"
  $unicorn_pid_file     = "$unicorn_run_path/cikl_api.pid"
  $unicorn_socket_path  = "$unicorn_run_path/socket"

  ensure_packages(['bundler'])

  file { $root: 
    ensure => "directory"
  } ->
  exec { 'profile::api::install':
    cwd         => $root,
    command     => "/usr/bin/bundle install --without development --path=${$gems} --gemfile=$local_path/Gemfile",
    require => [
      Package['bundler']
    ],
    notify  => Service['profile::api::service'],
    unless => "/usr/bin/bundle check --gemfile=$local_path/Gemfile"
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

  # Unicorn stuff
  file { 'profile::api::unicorn_run_path':
    path   => $unicorn_run_path,
    ensure => "directory",
    owner  => $user,
    group  => $group,
    require => [
      User['profile::api::user'],
      Group['profile::api::group']
    ]
  }

  file { 'profile::api::unicorn_log_path': 
    path   => $unicorn_log_path,
    ensure => "directory",
    owner  => $user,
    group  => $group,
    require => [
      User['profile::api::user'],
      Group['profile::api::group']
    ]
  }
  # 
  file { 'profile::api::unicorn_config': 
    path    => $unicorn_config,
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/api/unicorn.conf.erb'),
    notify  => Service['profile::api::service'],
    require => [
      File['profile::api::unicorn_log_path'],
      File['profile::api::unicorn_run_path']
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
      File['profile::api::unicorn_config'],
      File['profile::api::unicorn_log_path'],
      File['profile::api::unicorn_run_path']
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


