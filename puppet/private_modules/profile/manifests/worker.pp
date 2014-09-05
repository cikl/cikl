class profile::worker (
  $local_path,
  $root          = '/opt/cikl/worker',
  $gem_root      = '/opt/cikl/worker/gems',
  $user          = 'cikl_worker',
  $group         = 'cikl_worker',
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/',
  $server_config       = "/etc/cikl-dns-worker.yaml",
  $server_run_path     = '/var/run/cikl-dns-worker',
) inherits profile::base {

  ensure_packages(['libxml2-dev', 'libunbound2'])

  file { $root: 
    ensure => "directory"
  }

  bundler::install { "worker":
    source_path => $local_path,
    gem_root    => $gem_root,
    notify      => Service['profile::worker::service'],
    require => [
      Package['libunbound2', 'libxml2-dev']
    ],
  }

  group { 'profile::worker::group':
    name => $group,
    ensure => 'present'
  } ->
  user { 'profile::worker::user':
    name    => $user,
    ensure  => 'present',
    gid     => $group,
    shell   => '/usr/sbin/nologin'
  } -> 

  file { 'profile::worker::config': 
    path    => $server_config,
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/worker/cikl-dns-worker.yaml.erb'),
    notify  => Service['profile::worker::service']
  }

  file { 'profile::worker::upstart-pre': 
    path    => "/etc/init/cikl-dns-worker-pre.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/worker/cikl-dns-worker-pre-upstart.conf.erb'),
    notify  => Service['profile::worker::service'],
    require => [
      User['profile::worker::user'],
      Group['profile::worker::group'],
    ]
  }

  file { 'profile::worker::upstart': 
    path    => "/etc/init/cikl-dns-worker.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/worker/cikl-dns-worker-upstart.conf.erb'),
    notify  => Service['profile::worker::service'],
    require => [
      User['profile::worker::user'],
      Group['profile::worker::group'],
      File['profile::worker::config'],
      File['profile::worker::upstart-pre']
    ]
  }

  service { 'profile::worker::service': 
    name       => 'cikl-dns-worker',
    ensure     => 'running',
    provider   => 'upstart',
    hasstatus  => true,
    hasrestart => false, # This gets upstart to properly reload things.
    pattern    => 'dns_worker',
    subscribe  => [
      File['profile::worker::upstart', 'profile::worker::config']
    ]
  }

}

