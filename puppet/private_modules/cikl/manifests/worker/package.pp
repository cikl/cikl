class cikl::worker::package {

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

  exec { 'cikl::worker::package':
    cwd         => $worker_root,
    command     => "/usr/bin/bundle install --path=${$worker_gems} --gemfile=/vagrant/cikl-worker/Gemfile",
    require => [
      File[$worker_root],
      Package['cikl::worker::install::libunbound', 'cikl::worker::install::bundler']
    ],
    unless => '/usr/bin/bundle check --gemfile=/vagrant/cikl-worker/Gemfile'
  }
}


