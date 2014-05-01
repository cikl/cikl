class cikl_worker::config (
  $user          = 'cikl_worker',
  $group         = 'cikl_worker',
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/',
  )
{
  group { 'cikl_worker::config::group':
    name => $user,
    ensure => 'present'
  }

  user { 'cikl_worker::config::user':
    name    => $group,
    ensure  => 'present',
    gid     => $group,
    require => Group['cikl_worker::config::group'],
    shell   => '/usr/sbin/nologin'
  }

  file { 'cikl_worker::config::conf': 
    path    => "/etc/cikl-dns-worker.yaml",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl_worker/cikl-dns-worker.yaml.erb')
  }

  file { 'cikl_worker::config::upstart': 
    path    => "/etc/init/cikl-dns-worker.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl_worker/cikl-dns-worker-upstart.conf.erb'),
    require => [
      User['cikl_worker::config::user'],
      Group['cikl_worker::config::group'],
      File['cikl_worker::config::conf'],
    ]
  }
}
