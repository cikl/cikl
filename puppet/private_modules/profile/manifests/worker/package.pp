class cikl_worker::package {

  $worker_root = "/opt/worker"
  $worker_gems = "${worker_root}/gems"

  $worker_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

  package { 'cikl_worker::install::bundler':
    name => 'bundler'
  }

  package { 'cikl_worker::install::libunbound':
    name => 'libunbound2'
  }

  file { $worker_root: 
    ensure => "directory"
  }

  exec { 'cikl_worker::package':
    cwd         => $worker_root,
    command     => "/usr/bin/bundle install --path=${$worker_gems} --gemfile=/vagrant/cikl-worker/Gemfile",
    require => [
      File[$worker_root],
      Package['cikl_worker::install::libunbound', 'cikl_worker::install::bundler']
    ],
    unless => '/usr/bin/bundle check --gemfile=/vagrant/cikl-worker/Gemfile'
  }
}


