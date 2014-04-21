class cikl::worker::install {

  $worker_root = "/opt/worker"
  $worker_gems = "${worker_root}/gems"

  $worker_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

  package { 'cikl::worker::install::bundler':
    name => 'bundler'
  }

  package { 'cikl::worker::install::libunbound':
    name => 'libunbound2'
  }

  file { $worker_root: 
    ensure => "directory"
  }

  exec { 'cikl::worker::install::deps':
    cwd         => $worker_root,
    command     => "/usr/bin/bundle install --path=${$worker_gems} --gemfile=/vagrant/cikl-worker/Gemfile",
    require => [
      File[$worker_root],
      Package['cikl::worker::install::libunbound', 'cikl::worker::install::bundler']
    ],
    unless => '/usr/bin/bundle check --gemfile=/vagrant/cikl-worker/Gemfile'
  }

  file { 'cikl::worker::install::dns::conf': 
    path    => "/etc/cikl-dns-worker.yaml",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/cikl-dns-worker.yaml.erb')
  }

  file { 'cikl::worker::install::dns::upstart': 
    path    => "/etc/init/cikl-dns-worker.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('cikl/cikl-dns-worker-upstart.conf.erb')
  }

  service { 'cikl::worker::service': 
    name       => 'cikl-dns-worker',
    ensure     => 'running',
    provider   => 'upstart',
    hasstatus  => true,
    hasrestart => true,
    require  => [
      File['cikl::worker::install::dns::upstart', 'cikl::worker::install::dns::conf'],
      Exec['cikl::worker::install::deps']
    ],
    pattern => 'dns_worker'
  }


}



