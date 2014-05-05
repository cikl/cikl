class profile::smrt (
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/'
) inherits profile::base {

  $smrt_perllib_dir  = '/opt/cikl/smrt'

  $perl5lib = "/vagrant/p5-Cikl/lib:/vagrant/p5-Cikl-RabbitMQ/lib:$smrt_perllib_dir/lib/perl5"
  $append_to_path = "/vagrant/p5-Cikl/bin"

  class profile::smrt::deps {
    ensure_packages([
      'cpanminus', 'build-essential', 'libxml2-dev', 'libssl-dev'
      ])
  }

  include profile::smrt::deps

  if (!defined(File['/opt/cikl'])) {
    file { "/opt/cikl":
      ensure => directory
    }
  }

  file { $smrt_perllib_dir: 
    ensure => directory
  }

  file { 'cikl-conf': 
    path    => "/etc/cikl.conf",
    owner   => "root",
    group   => "root",
    mode    => '0644',
    content => template('profile/smrt/cikl.conf.erb')
  }

  exec { 'profile::smrt::install':
    command     => "/usr/bin/cpanm --notest -l $smrt_perllib_dir --installdeps /vagrant/p5-Cikl",
    environment => "PERL5LIB=$perl5lib",
    require => [ 
      Class['profile::smrt::deps'],
      File[$smrt_perllib_dir]
    ]
  }

  exec { 'profile::smrt::install_rabbitmq':
    command => "/usr/bin/cpanm --notest -l $smrt_perllib_dir --installdeps /vagrant/p5-Cikl-RabbitMQ",
    environment => "PERL5LIB=$perl5lib",
    require => [ 
      Class['profile::smrt::deps'],
      File[$smrt_perllib_dir],
      Exec['profile::smrt::install']
    ]
  }

  file { "/etc/profile.d/cikl_profile.sh":
    content => template('profile/smrt/profile.sh.erb')
  }
}


