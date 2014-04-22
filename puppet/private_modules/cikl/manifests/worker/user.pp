class cikl::worker::user {
  group { 'cikl::worker::user':
    name => $cikl::worker_group,
    ensure => 'present'
  }

  user { 'cikl::worker::user':
    name    => $cikl::worker_user,
    ensure  => 'present',
    gid     => $cikl::worker_group,
    require => Group['cikl::worker::user'],
    shell   => '/usr/sbin/nologin'
  }
}

