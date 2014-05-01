class cikl_worker::service {
  service { 'cikl_worker::service': 
    name       => 'cikl-dns-worker',
    ensure     => 'running',
    provider   => 'upstart',
    hasstatus  => true,
    hasrestart => true,
    pattern    => 'dns_worker',
    subscribe  => Class['cikl_worker::config']
  }
}
