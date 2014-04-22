class cikl::worker::config {
  file { 'cikl::worker::config::conf': 
    path    => "/etc/cikl-dns-worker.yaml",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/cikl-dns-worker.yaml.erb')
  }

  file { 'cikl::worker::config::upstart': 
    path    => "/etc/init/cikl-dns-worker.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/cikl-dns-worker-upstart.conf.erb')
  }
}
