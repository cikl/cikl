class cikl::worker::service {
  service { 'cikl::worker::service': 
    name       => 'cikl-dns-worker',
    ensure     => 'running',
    provider   => 'upstart',
    hasstatus  => true,
    hasrestart => true,
    pattern    => 'dns_worker',
    subscribe  => Class['cikl::worker::config']
  }
}
