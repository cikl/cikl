class cikl::nginx::service () {
  include cikl::nginx::params
  service { 'cikl::nginx::service':
    name       => 'nginx',
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File[$cikl::nginx::params::configfile],
    pattern    => 'nginx'
  }
}

