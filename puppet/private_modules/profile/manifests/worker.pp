class profile::worker (
  $local_path,
  $root          = '/opt/worker',
  $user          = 'cikl_worker',
  $group         = 'cikl_worker',
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/',
) inherits profile::base {
  $gems = "$root/gems"

  include profile::bundler
  ensure_packages(['libunbound2'])

  file { $root: 
    ensure => "directory"
  } ->
  exec { 'profile::worker::install':
    cwd         => $root,
    command     => "/usr/local/bin/bundle install --jobs=7 --without development --path=${$gems} --gemfile=$local_path/Gemfile",
    require => [
      Package['libunbound2', 'bundler']
    ],
    notify  => Service['profile::worker::service'],
    unless => "/usr/local/bin/bundle check --gemfile=$local_path/Gemfile"
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
  }

  file { 'profile::worker::config': 
    path    => "/etc/cikl-dns-worker.yaml",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/worker/cikl-dns-worker.yaml.erb'),
    notify  => Service['profile::worker::service']
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
      Group['profile::worker::group']
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

