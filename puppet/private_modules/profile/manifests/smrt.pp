class profile::smrt (
  $rabbitmq_host = 'localhost',
  $rabbitmq_port = 5672,
  $rabbitmq_username = 'guest',
  $rabbitmq_password = 'guest',
  $rabbitmq_vhost = '/',
  $local_p5_cikl            = undef,
  $local_p5_cikl_rabbitmq   = undef,
) inherits profile::base {

  $smrt_perllib_dir  = '/opt/cikl/smrt'

  if ($local_p5_cikl == undef) {
    $p5_cikl_libpath = []
    $p5_cikl_binpath = []
    $p5_cikl_install_args = "Cikl"
  } else {
    $p5_cikl_libpath = ["$local_p5_cikl/lib"]
    $p5_cikl_binpath = ["$local_p5_cikl/bin"]
    validate_absolute_path($local_p5_cikl)
    $p5_cikl_install_args = "--installdeps $local_p5_cikl"
  }

  if ($local_p5_cikl_rabbitmq == undef) {
    $p5_cikl_rabbitmq_libpath = []
    $p5_cikl_rabbitmq_binpath = []
    $p5_cikl_rabbitmq_install_args = "Cikl::RabbitMQ"
  } else {
    $p5_cikl_rabbitmq_libpath = ["$local_p5_cikl_rabbitmq/lib"]
    $p5_cikl_rabbitmq_binpath = ["$local_p5_cikl_rabbitmq/bin"]
    validate_absolute_path($local_p5_cikl)
    $p5_cikl_rabbitmq_install_args = "--installdeps $local_p5_cikl_rabbitmq"
  }

  $perl5lib = join(flatten(
    [
      $p5_cikl_libpath,
      $p5_cikl_rabbitmq_libpath,
      ["$smrt_perllib_dir/lib/perl5"]
    ]
  ), ":")

  $append_to_path = join(flatten(
    [
      $p5_cikl_binpath,
      $p5_cikl_rabbitmq_binpath,
      ["$smrt_perllib_dir/bin"]
    ]
  ), ":")

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
    # Template uses the following variables:
    #  $rabbitmq_host
    #  $rabbitmq_port
    #  $rabbitmq_username
    #  $rabbitmq_password
    #  $rabbitmq_vhost
    content => template('profile/smrt/cikl.conf.erb')
  }

  exec { 'profile::smrt::install':
    command     => "/usr/bin/cpanm --notest -l $smrt_perllib_dir --no-man-pages --save-dists $smrt_perllib_dir/cache $p5_cikl_install_args",
    environment => "PERL5LIB=$perl5lib",
    require => [ 
      Class['profile::smrt::deps'],
      File[$smrt_perllib_dir]
    ]
  }

  exec { 'profile::smrt::install_rabbitmq':
    command => "/usr/bin/cpanm --notest -l $smrt_perllib_dir --no-man-pages --save-dists $smrt_perllib_dir/cache $p5_cikl_rabbitmq_install_args",
    environment => "PERL5LIB=$perl5lib",
    require => [ 
      Class['profile::smrt::deps'],
      File[$smrt_perllib_dir],
      Exec['profile::smrt::install']
    ]
  }

  file { "/etc/profile.d/cikl_profile.sh":
    # Templates uses the following variables:
    #  $append_to_path
    #  $perl5lib
    content => template('profile/smrt/profile.sh.erb')
  }
}


